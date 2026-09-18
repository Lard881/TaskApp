-- ============================================================
-- PlanPal — Initial Schema
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- ============================================================

-- ── Extensions ───────────────────────────────────────────────────────────────
create extension if not exists "pgcrypto";
create extension if not exists "citext";

-- ============================================================
-- STEP 1: CREATE ALL TABLES FIRST (no RLS policies yet)
-- ============================================================

-- ── PROFILES ─────────────────────────────────────────────────────────────────
create table if not exists public.profiles (
  id            uuid        primary key references auth.users(id) on delete cascade,
  first_name    text        not null default '',
  last_name     text        not null default '',
  email         citext      not null default '',
  avatar_url    text,
  role          text,
  phone         text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- ── WORKSPACES ────────────────────────────────────────────────────────────────
create table if not exists public.workspaces (
  id            uuid        primary key default gen_random_uuid(),
  name          text        not null,
  type          text        not null default 'personal' check (type in ('personal', 'team')),
  emoji         text        not null default '🗂️',
  created_by    uuid        not null references public.profiles(id) on delete cascade,
  created_at    timestamptz not null default now()
);

-- ── WORKSPACE MEMBERS ─────────────────────────────────────────────────────────
create table if not exists public.workspace_members (
  id              uuid        primary key default gen_random_uuid(),
  workspace_id    uuid        not null references public.workspaces(id) on delete cascade,
  user_id         uuid        not null references public.profiles(id) on delete cascade,
  role            text        not null default 'member' check (role in ('owner', 'admin', 'member')),
  joined_at       timestamptz not null default now(),
  unique (workspace_id, user_id)
);

-- ── WORKSPACE INVITES ─────────────────────────────────────────────────────────
create table if not exists public.workspace_invites (
  id              uuid        primary key default gen_random_uuid(),
  workspace_id    uuid        not null references public.workspaces(id) on delete cascade,
  invite_code     text        not null unique default substring(gen_random_uuid()::text, 1, 8),
  invited_email   citext,
  created_by      uuid        not null references public.profiles(id),
  expires_at      timestamptz not null default now() + interval '7 days',
  used_at         timestamptz,
  used_by         uuid        references public.profiles(id)
);

-- ── TASKS ─────────────────────────────────────────────────────────────────────
create table if not exists public.tasks (
  id              uuid        primary key default gen_random_uuid(),
  workspace_id    uuid        not null references public.workspaces(id) on delete cascade,
  name            text        not null check (char_length(name) <= 100),
  description     text        check (char_length(description) <= 500),
  priority        text        not null default 'medium' check (priority in ('high', 'medium', 'low')),
  status          text        not null default 'todo' check (status in ('todo', 'in_progress', 'completed')),
  due_date        date,
  due_time        time,
  assignee_id     uuid        references public.profiles(id) on delete set null,
  created_by      uuid        not null references public.profiles(id),
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- ── CONVERSATIONS ─────────────────────────────────────────────────────────────
create table if not exists public.conversations (
  id                    uuid        primary key default gen_random_uuid(),
  workspace_id          uuid        not null references public.workspaces(id) on delete cascade,
  name                  text        not null default '',
  is_group              boolean     not null default false,
  participant_ids       uuid[]      not null default '{}',
  last_message_preview  text        not null default '',
  last_message_at       timestamptz not null default now(),
  unread_count          int         not null default 0,
  created_at            timestamptz not null default now()
);

-- ── MESSAGES ──────────────────────────────────────────────────────────────────
create table if not exists public.messages (
  id                uuid        primary key default gen_random_uuid(),
  conversation_id   uuid        not null references public.conversations(id) on delete cascade,
  sender_id         uuid        not null references public.profiles(id),
  text              text        not null check (char_length(text) > 0),
  is_read           boolean     not null default false,
  sent_at           timestamptz not null default now()
);

-- ── ACTIVITY ITEMS ────────────────────────────────────────────────────────────
create table if not exists public.activity_items (
  id          uuid        primary key default gen_random_uuid(),
  user_id     uuid        not null references public.profiles(id) on delete cascade,
  type        text        not null check (type in ('created', 'updated', 'completed')),
  task_id     uuid        references public.tasks(id) on delete set null,
  task_name   text        not null,
  timestamp   timestamptz not null default now()
);

-- ── PREFERENCES ───────────────────────────────────────────────────────────────
create table if not exists public.preferences (
  user_id                   uuid        primary key references public.profiles(id) on delete cascade,
  theme_mode                text        not null default 'light' check (theme_mode in ('light', 'dark', 'system')),
  language_code             text        not null default 'en',
  timezone_id               text        not null default 'UTC',
  notify_task_reminders     boolean     not null default true,
  notify_due_date_alerts    boolean     not null default true,
  notify_chat_messages      boolean     not null default true,
  notify_weekly_summary     boolean     not null default false,
  updated_at                timestamptz not null default now()
);

-- ============================================================
-- STEP 2: ENABLE ROW LEVEL SECURITY ON ALL TABLES
-- ============================================================

alter table public.profiles          enable row level security;
alter table public.workspaces        enable row level security;
alter table public.workspace_members enable row level security;
alter table public.workspace_invites enable row level security;
alter table public.tasks             enable row level security;
alter table public.conversations     enable row level security;
alter table public.messages          enable row level security;
alter table public.activity_items    enable row level security;
alter table public.preferences       enable row level security;

-- ============================================================
-- STEP 3: RLS POLICIES (all tables exist now — no forward refs)
-- ============================================================

-- ── PROFILES policies ─────────────────────────────────────────────────────────
create policy "profiles: anyone can read"
  on public.profiles for select
  using (true);

create policy "profiles: owner can update"
  on public.profiles for update
  using (auth.uid() = id);

create policy "profiles: owner can insert"
  on public.profiles for insert
  with check (auth.uid() = id);

-- ── WORKSPACES policies ───────────────────────────────────────────────────────
create policy "workspaces: members can read"
  on public.workspaces for select
  using (
    exists (
      select 1 from public.workspace_members wm
      where wm.workspace_id = public.workspaces.id
        and wm.user_id = auth.uid()
    )
  );

create policy "workspaces: authenticated can insert"
  on public.workspaces for insert
  with check (auth.uid() = created_by);

create policy "workspaces: owner can update"
  on public.workspaces for update
  using (created_by = auth.uid());

create policy "workspaces: owner can delete"
  on public.workspaces for delete
  using (created_by = auth.uid());

-- ── WORKSPACE MEMBERS policies ────────────────────────────────────────────────
create policy "workspace_members: members can read"
  on public.workspace_members for select
  using (
    exists (
      select 1 from public.workspace_members wm2
      where wm2.workspace_id = public.workspace_members.workspace_id
        and wm2.user_id = auth.uid()
    )
  );

create policy "workspace_members: owner/admin or self can insert"
  on public.workspace_members for insert
  with check (
    auth.uid() = user_id
    or exists (
      select 1 from public.workspace_members wm2
      where wm2.workspace_id = public.workspace_members.workspace_id
        and wm2.user_id = auth.uid()
        and wm2.role in ('owner', 'admin')
    )
  );

create policy "workspace_members: owner or self can delete"
  on public.workspace_members for delete
  using (
    user_id = auth.uid()
    or exists (
      select 1 from public.workspace_members wm2
      where wm2.workspace_id = public.workspace_members.workspace_id
        and wm2.user_id = auth.uid()
        and wm2.role = 'owner'
    )
  );

-- ── WORKSPACE INVITES policies ────────────────────────────────────────────────
create policy "invites: anyone can read"
  on public.workspace_invites for select
  using (true);

create policy "invites: owner/admin can insert"
  on public.workspace_invites for insert
  with check (
    exists (
      select 1 from public.workspace_members wm
      where wm.workspace_id = public.workspace_invites.workspace_id
        and wm.user_id = auth.uid()
        and wm.role in ('owner', 'admin')
    )
  );

create policy "invites: owner/admin can update"
  on public.workspace_invites for update
  using (
    exists (
      select 1 from public.workspace_members wm
      where wm.workspace_id = public.workspace_invites.workspace_id
        and wm.user_id = auth.uid()
        and wm.role in ('owner', 'admin')
    )
    or auth.uid() = used_by
  );

-- ── TASKS policies ────────────────────────────────────────────────────────────
create policy "tasks: workspace members can read"
  on public.tasks for select
  using (
    exists (
      select 1 from public.workspace_members wm
      where wm.workspace_id = public.tasks.workspace_id
        and wm.user_id = auth.uid()
    )
  );

create policy "tasks: workspace members can insert"
  on public.tasks for insert
  with check (
    auth.uid() = created_by
    and exists (
      select 1 from public.workspace_members wm
      where wm.workspace_id = public.tasks.workspace_id
        and wm.user_id = auth.uid()
    )
  );

create policy "tasks: creator or assignee or admin can update"
  on public.tasks for update
  using (
    created_by = auth.uid()
    or assignee_id = auth.uid()
    or exists (
      select 1 from public.workspace_members wm
      where wm.workspace_id = public.tasks.workspace_id
        and wm.user_id = auth.uid()
        and wm.role in ('owner', 'admin')
    )
  );

create policy "tasks: creator or admin can delete"
  on public.tasks for delete
  using (
    created_by = auth.uid()
    or exists (
      select 1 from public.workspace_members wm
      where wm.workspace_id = public.tasks.workspace_id
        and wm.user_id = auth.uid()
        and wm.role in ('owner', 'admin')
    )
  );

-- ── CONVERSATIONS policies ────────────────────────────────────────────────────
create policy "conversations: participants can read"
  on public.conversations for select
  using (auth.uid() = any(participant_ids));

create policy "conversations: participants can insert"
  on public.conversations for insert
  with check (auth.uid() = any(participant_ids));

create policy "conversations: participants can update"
  on public.conversations for update
  using (auth.uid() = any(participant_ids));

create policy "conversations: participants can delete"
  on public.conversations for delete
  using (auth.uid() = any(participant_ids));

-- ── MESSAGES policies ─────────────────────────────────────────────────────────
create policy "messages: participants can read"
  on public.messages for select
  using (
    exists (
      select 1 from public.conversations c
      where c.id = public.messages.conversation_id
        and auth.uid() = any(c.participant_ids)
    )
  );

create policy "messages: sender can insert"
  on public.messages for insert
  with check (
    auth.uid() = sender_id
    and exists (
      select 1 from public.conversations c
      where c.id = public.messages.conversation_id
        and auth.uid() = any(c.participant_ids)
    )
  );

create policy "messages: sender can update"
  on public.messages for update
  using (sender_id = auth.uid());

create policy "messages: sender can delete"
  on public.messages for delete
  using (sender_id = auth.uid());

-- ── ACTIVITY ITEMS policies ───────────────────────────────────────────────────
create policy "activity: user can read own"
  on public.activity_items for select
  using (user_id = auth.uid());

create policy "activity: user can insert own"
  on public.activity_items for insert
  with check (user_id = auth.uid());

-- ── PREFERENCES policies ──────────────────────────────────────────────────────
create policy "preferences: user can read own"
  on public.preferences for select
  using (user_id = auth.uid());

create policy "preferences: user can insert own"
  on public.preferences for insert
  with check (user_id = auth.uid());

create policy "preferences: user can update own"
  on public.preferences for update
  using (user_id = auth.uid());

-- ============================================================
-- STEP 4: FUNCTIONS AND TRIGGERS
-- ============================================================

-- ── Auto-create profile on new auth user ──────────────────────────────────────
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, first_name, last_name, email, avatar_url)
  values (
    new.id,
    coalesce(
      new.raw_user_meta_data->>'given_name',
      split_part(coalesce(new.raw_user_meta_data->>'full_name', ''), ' ', 1),
      ''
    ),
    coalesce(
      new.raw_user_meta_data->>'family_name',
      case
        when array_length(
          string_to_array(coalesce(new.raw_user_meta_data->>'full_name', ''), ' '), 1
        ) > 1
        then split_part(coalesce(new.raw_user_meta_data->>'full_name', ''), ' ', 2)
        else ''
      end,
      ''
    ),
    coalesce(new.email, ''),
    new.raw_user_meta_data->>'avatar_url'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ── Auto-create personal workspace + default preferences on new profile ────────
create or replace function public.handle_new_profile()
returns trigger language plpgsql security definer
set search_path = public
as $$
declare
  v_workspace_id uuid;
  v_workspace_name text;
begin
  -- Build workspace name
  v_workspace_name := case
    when new.first_name <> '' then new.first_name || '''s Workspace'
    else 'My Workspace'
  end;

  -- Create personal workspace
  insert into public.workspaces (name, type, emoji, created_by)
  values (v_workspace_name, 'personal', '🗂️', new.id)
  returning id into v_workspace_id;

  -- Add user as owner
  insert into public.workspace_members (workspace_id, user_id, role)
  values (v_workspace_id, new.id, 'owner');

  -- Create default preferences
  insert into public.preferences (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_profile_created on public.profiles;
create trigger on_profile_created
  after insert on public.profiles
  for each row execute procedure public.handle_new_profile();

-- ── Auto-update tasks.updated_at ─────────────────────────────────────────────
create or replace function public.handle_updated_at()
returns trigger language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists tasks_updated_at on public.tasks;
create trigger tasks_updated_at
  before update on public.tasks
  for each row execute procedure public.handle_updated_at();

-- ── Auto-update conversation preview when a message is sent ──────────────────
create or replace function public.handle_new_message()
returns trigger language plpgsql security definer
set search_path = public
as $$
begin
  update public.conversations
  set
    last_message_preview = new.text,
    last_message_at      = new.sent_at
  where id = new.conversation_id;
  return new;
end;
$$;

drop trigger if exists on_new_message on public.messages;
create trigger on_new_message
  after insert on public.messages
  for each row execute procedure public.handle_new_message();

-- ============================================================
-- STEP 5: ENABLE REALTIME
-- ============================================================

alter publication supabase_realtime add table public.messages;
alter publication supabase_realtime add table public.conversations;
alter publication supabase_realtime add table public.tasks;
alter publication supabase_realtime add table public.activity_items;
