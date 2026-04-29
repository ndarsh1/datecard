-- DateCard Initial Schema
-- Run this in your Supabase SQL Editor or via supabase db push

-- ============================================================
-- EXTENSIONS
-- ============================================================
create extension if not exists "uuid-ossp";

-- ============================================================
-- USERS
-- ============================================================
create table public.users (
    id uuid primary key default uuid_generate_v4(),
    auth_id uuid unique references auth.users(id) on delete cascade,
    phone varchar(20) unique not null,
    name varchar(100),
    age integer,
    photos text[] default '{}',
    latitude double precision,
    longitude double precision,
    date_style_card jsonb default '{}',
    favorite_date_types text[] default '{}',
    dream_date text,
    verified_photo boolean default false,
    verified_id boolean default false,
    onboarding_complete boolean default false,
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

alter table public.users enable row level security;

-- Users can read their own profile
create policy "users_select_own" on public.users
    for select using (auth.uid() = auth_id);

-- Users can update their own profile
create policy "users_update_own" on public.users
    for update using (auth.uid() = auth_id);

-- Users can insert their own profile
create policy "users_insert_own" on public.users
    for insert with check (auth.uid() = auth_id);

-- ============================================================
-- BLOCKED USERS
-- ============================================================
create table public.blocked_users (
    id uuid primary key default uuid_generate_v4(),
    blocker_id uuid not null references public.users(id) on delete cascade,
    blocked_id uuid not null references public.users(id) on delete cascade,
    created_at timestamptz default now(),
    unique(blocker_id, blocked_id)
);

alter table public.blocked_users enable row level security;

create policy "blocked_users_own" on public.blocked_users
    for all using (
        blocker_id in (select id from public.users where auth_id = auth.uid())
    );

-- ============================================================
-- DATE EXPERIENCES
-- ============================================================
create table public.date_experiences (
    id uuid primary key default uuid_generate_v4(),
    title varchar(200) not null,
    description text,
    categories text[] default '{}',
    venue_id uuid,
    price_range integer check (price_range between 1 and 3),
    duration_minutes integer,
    latitude double precision,
    longitude double precision,
    neighborhood varchar(100),
    hero_image text,
    gallery_images text[] default '{}',
    opt_in_count integer default 0,
    source varchar(20) default 'editorial',
    is_venue_package boolean default false,
    expires_at timestamptz,
    created_at timestamptz default now()
);

alter table public.date_experiences enable row level security;

-- Anyone authenticated can read experiences
create policy "experiences_select_all" on public.date_experiences
    for select using (auth.role() = 'authenticated');

-- ============================================================
-- OPT-INS
-- ============================================================
create table public.opt_ins (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid not null references public.users(id) on delete cascade,
    experience_id uuid not null references public.date_experiences(id) on delete cascade,
    created_at timestamptz default now(),
    unique(user_id, experience_id)
);

alter table public.opt_ins enable row level security;

-- Users can insert their own opt-ins
create policy "opt_ins_insert_own" on public.opt_ins
    for insert with check (
        user_id in (select id from public.users where auth_id = auth.uid())
    );

-- Users can read opt-ins for experiences they've opted into
create policy "opt_ins_select" on public.opt_ins
    for select using (
        user_id in (select id from public.users where auth_id = auth.uid())
        or experience_id in (
            select experience_id from public.opt_ins
            where user_id in (select id from public.users where auth_id = auth.uid())
        )
    );

-- ============================================================
-- MATCHES
-- ============================================================
create table public.matches (
    id uuid primary key default uuid_generate_v4(),
    user_a uuid not null references public.users(id) on delete cascade,
    user_b uuid not null references public.users(id) on delete cascade,
    experience_id uuid references public.date_experiences(id),
    plus_one_post_id uuid,
    status varchar(20) default 'pending' check (status in ('pending', 'matched', 'confirmed', 'completed')),
    chat_channel_id varchar(100),
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

alter table public.matches enable row level security;

-- Users can read matches they're part of
create policy "matches_select_own" on public.matches
    for select using (
        user_a in (select id from public.users where auth_id = auth.uid())
        or user_b in (select id from public.users where auth_id = auth.uid())
    );

-- ============================================================
-- PLUS ONE POSTS
-- ============================================================
create table public.plus_one_posts (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid not null references public.users(id) on delete cascade,
    event_name varchar(200) not null,
    event_type varchar(20) not null check (event_type in ('wedding', 'gala', 'concert', 'party', 'sports', 'other')),
    event_date timestamptz not null,
    location_name varchar(200),
    latitude double precision,
    longitude double precision,
    dress_code varchar(100),
    vibe varchar(200),
    ticket_included boolean default false,
    description text,
    expires_at timestamptz,
    created_at timestamptz default now()
);

alter table public.plus_one_posts enable row level security;

-- Anyone authenticated can read non-expired posts
create policy "board_select_all" on public.plus_one_posts
    for select using (
        auth.role() = 'authenticated'
        and (expires_at is null or expires_at > now())
    );

-- Users can insert their own posts
create policy "board_insert_own" on public.plus_one_posts
    for insert with check (
        user_id in (select id from public.users where auth_id = auth.uid())
    );

-- Users can update/delete their own posts
create policy "board_update_own" on public.plus_one_posts
    for update using (
        user_id in (select id from public.users where auth_id = auth.uid())
    );

-- ============================================================
-- PLUS ONE INTERESTS
-- ============================================================
create table public.plus_one_interests (
    id uuid primary key default uuid_generate_v4(),
    post_id uuid not null references public.plus_one_posts(id) on delete cascade,
    user_id uuid not null references public.users(id) on delete cascade,
    note text,
    status varchar(20) default 'pending' check (status in ('pending', 'accepted', 'passed')),
    created_at timestamptz default now(),
    unique(post_id, user_id)
);

alter table public.plus_one_interests enable row level security;

-- Users can insert interest on others' posts
create policy "interests_insert_own" on public.plus_one_interests
    for insert with check (
        user_id in (select id from public.users where auth_id = auth.uid())
    );

-- Post creators can see interests on their posts; users can see their own interests
create policy "interests_select" on public.plus_one_interests
    for select using (
        user_id in (select id from public.users where auth_id = auth.uid())
        or post_id in (
            select id from public.plus_one_posts
            where user_id in (select id from public.users where auth_id = auth.uid())
        )
    );

-- Post creators can update interest status (accept/pass)
create policy "interests_update_creator" on public.plus_one_interests
    for update using (
        post_id in (
            select id from public.plus_one_posts
            where user_id in (select id from public.users where auth_id = auth.uid())
        )
    );

-- ============================================================
-- VENUES (Sprint 4)
-- ============================================================
create table public.venues (
    id uuid primary key default uuid_generate_v4(),
    name varchar(200) not null,
    address text,
    latitude double precision,
    longitude double precision,
    description text,
    photos text[] default '{}',
    stripe_connect_account_id varchar(100),
    category varchar(50),
    price_range integer check (price_range between 1 and 3),
    created_at timestamptz default now()
);

alter table public.venues enable row level security;

create policy "venues_select_all" on public.venues
    for select using (auth.role() = 'authenticated');

-- Add foreign key from date_experiences to venues
alter table public.date_experiences
    add constraint fk_venue foreign key (venue_id) references public.venues(id);

-- ============================================================
-- VENUE PACKAGES (Sprint 4)
-- ============================================================
create table public.venue_packages (
    id uuid primary key default uuid_generate_v4(),
    venue_id uuid not null references public.venues(id) on delete cascade,
    name varchar(200) not null,
    description text,
    price_cents integer not null,
    includes text[] default '{}',
    available boolean default true,
    created_at timestamptz default now()
);

alter table public.venue_packages enable row level security;

create policy "venue_packages_select_all" on public.venue_packages
    for select using (auth.role() = 'authenticated');

-- ============================================================
-- BOOKINGS (Sprint 4)
-- ============================================================
create table public.bookings (
    id uuid primary key default uuid_generate_v4(),
    match_id uuid references public.matches(id),
    venue_id uuid not null references public.venues(id),
    package_id uuid references public.venue_packages(id),
    user_id uuid not null references public.users(id),
    stripe_payment_intent_id varchar(100),
    amount_cents integer not null,
    status varchar(20) default 'pending' check (status in ('pending', 'confirmed', 'cancelled', 'completed')),
    booked_at timestamptz default now()
);

alter table public.bookings enable row level security;

create policy "bookings_own" on public.bookings
    for all using (
        user_id in (select id from public.users where auth_id = auth.uid())
    );

-- ============================================================
-- DATE RATINGS (Sprint 4)
-- ============================================================
create table public.date_ratings (
    id uuid primary key default uuid_generate_v4(),
    match_id uuid not null references public.matches(id),
    rater_id uuid not null references public.users(id),
    overall_score integer not null check (overall_score between 1 and 5),
    would_go_again boolean,
    feedback_text text,
    created_at timestamptz default now(),
    unique(match_id, rater_id)
);

alter table public.date_ratings enable row level security;

create policy "ratings_insert_own" on public.date_ratings
    for insert with check (
        rater_id in (select id from public.users where auth_id = auth.uid())
    );

create policy "ratings_select_own" on public.date_ratings
    for select using (
        rater_id in (select id from public.users where auth_id = auth.uid())
    );

-- ============================================================
-- REPORTS
-- ============================================================
create table public.reports (
    id uuid primary key default uuid_generate_v4(),
    reporter_id uuid not null references public.users(id),
    reported_id uuid not null references public.users(id),
    reason varchar(50) not null,
    details text,
    created_at timestamptz default now()
);

alter table public.reports enable row level security;

create policy "reports_insert_own" on public.reports
    for insert with check (
        reporter_id in (select id from public.users where auth_id = auth.uid())
    );

-- ============================================================
-- HELPER: Public profiles for matched users (read-only view)
-- ============================================================
create or replace view public.public_profiles as
select
    u.id,
    u.name,
    u.age,
    u.photos,
    u.date_style_card,
    u.favorite_date_types,
    u.dream_date,
    u.verified_photo,
    u.verified_id
from public.users u;

-- ============================================================
-- FUNCTIONS
-- ============================================================

-- Auto-update updated_at timestamp
create or replace function public.update_updated_at()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

create trigger users_updated_at
    before update on public.users
    for each row execute function public.update_updated_at();

create trigger matches_updated_at
    before update on public.matches
    for each row execute function public.update_updated_at();

-- Increment opt-in count when a new opt-in is created
create or replace function public.increment_opt_in_count()
returns trigger as $$
begin
    update public.date_experiences
    set opt_in_count = opt_in_count + 1
    where id = new.experience_id;
    return new;
end;
$$ language plpgsql;

create trigger opt_in_count_trigger
    after insert on public.opt_ins
    for each row execute function public.increment_opt_in_count();
