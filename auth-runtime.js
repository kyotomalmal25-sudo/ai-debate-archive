(function () {
  function createClient(url, anonKey, options) {
    const storageKey = `sb-${new URL(url).hostname.split('.')[0]}-auth-token`;
    const listeners = new Set();
    const readSession = () => {
      try { return JSON.parse(localStorage.getItem(storageKey) || 'null'); } catch (_) { return null; }
    };
    const writeSession = session => {
      if (session) localStorage.setItem(storageKey, JSON.stringify(session));
      else localStorage.removeItem(storageKey);
    };
    const notify = (event, session) => listeners.forEach(callback => callback(event, session));
    const headers = extra => Object.assign({ apikey: anonKey, 'Content-Type': 'application/json' }, extra || {});
    const auth = {
      onAuthStateChange(callback) { listeners.add(callback); callback('INITIAL_SESSION', readSession()); return { data: { subscription: { unsubscribe: () => listeners.delete(callback) } } }; },
      async getSession() { return { data: { session: readSession() }, error: null }; },
      async signInWithPassword({ email, password }) {
        try {
          const response = await fetch(`${url.replace(/\/$/, '')}/auth/v1/token?grant_type=password`, { method: 'POST', headers: headers(), body: JSON.stringify({ email, password }) });
          const body = await response.json().catch(() => ({}));
          if (!response.ok) return { data: { user: null, session: null }, error: body }; 
          writeSession(body);
          notify('SIGNED_IN', body);
          return { data: { user: body.user, session: body }, error: null };
        } catch (error) { return { data: { user: null, session: null }, error }; }
      },
      async signOut() {
        const session = readSession();
        try {
          if (session?.access_token) await fetch(`${url.replace(/\/$/, '')}/auth/v1/logout`, { method: 'POST', headers: headers({ Authorization: `Bearer ${session.access_token}` }) });
        } finally { writeSession(null); notify('SIGNED_OUT', null); }
        return { error: null };
      }
    };
    return { auth };
  }
  window.supabase = { createClient };
}());
