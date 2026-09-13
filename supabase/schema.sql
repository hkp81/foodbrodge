create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  created_at timestamptz not null default now()
);

create table public.listings (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  type text not null check (type in ('donation', 'sell')),
  provider_name text not null,
  provider_type text not null default 'Community provider',
  food_name text not null,
  description text not null default '',
  food_category text not null,
  vegetarian boolean not null default false,
  quantity integer not null check (quantity > 0),
  meals integer not null check (meals > 0),
  available_quantity integer not null check (available_quantity >= 0),
  address text not null,
  latitude double precision not null,
  longitude double precision not null,
  created_at timestamptz not null default now(),
  pickup_deadline timestamptz not null,
  claim_deadline timestamptz,
  reservation_deadline timestamptz,
  status text not null default 'active' check (status in ('active', 'claimed', 'reserved', 'expired')),
  collection_instructions text not null default '',
  original_price numeric,
  discounted_price numeric,
  discount_percentage integer not null default 0,
  reserved_quantity integer not null default 0,
  claimed_by uuid references auth.users(id),
  claimed_at timestamptz
);

alter table public.profiles enable row level security;
alter table public.listings enable row level security;

create policy "Profiles are publicly readable" on public.profiles for select using (true);
create policy "Users create their own profile" on public.profiles for insert with check (auth.uid() = id);
create policy "Users update their own profile" on public.profiles for update using (auth.uid() = id);

create policy "Anyone can read active listings" on public.listings for select using (status = 'active' or auth.uid() = owner_id);
create policy "Signed-in users create listings" on public.listings for insert with check (auth.uid() = owner_id);
create policy "Users update active listings or their own" on public.listings for update using (auth.uid() = owner_id or status = 'active') with check (auth.uid() = owner_id or status in ('active', 'claimed', 'reserved'));
create policy "Owners delete listings" on public.listings for delete using (auth.uid() = owner_id);

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public
as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'display_name', split_part(new.email, '@', 1)));
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
