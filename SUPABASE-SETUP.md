# Supabase setup

1. Open the existing Supabase project and run `supabase-schema.sql` in the SQL Editor.
2. In Authentication > Users, copy the UUID of the existing administrator account.
3. Run this statement in the SQL Editor, replacing the placeholder:

```sql
insert into public.admin_users (user_id)
values ('REPLACE_WITH_ADMIN_USER_UUID');
```

The public site uses only the publishable anon key. Logs can be selected by anonymous visitors; the RLS policies allow insert, update, and delete only when the signed-in user's UUID is present in `admin_users`.

Existing browser-local logs are not published automatically. After signing in to Admin, use “Download local migration” to export them for review and publish selected logs manually.

The Contact form remains on FormSubmit and still targets the existing address. FormSubmit may require its one-time recipient activation before the first message is delivered.
