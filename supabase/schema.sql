-- مزرعتي: مخطط قاعدة البيانات الأولي لـ Supabase/Postgres
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique not null check (char_length(username) between 3 and 20),
  display_name text not null default 'مزارع جديد',
  level integer not null default 1 check (level >= 1),
  xp bigint not null default 0 check (xp >= 0),
  dinar bigint not null default 250000 check (dinar >= 0),
  premium_coins bigint not null default 0 check (premium_coins >= 0),
  created_at timestamptz not null default now()
);

create table if not exists public.farms (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null unique references public.profiles(id) on delete cascade,
  farm_name text not null default 'مزرعتي',
  farm_level integer not null default 1,
  layout jsonb not null default '{"plots":[],"decorations":[]}'::jsonb,
  is_public boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.catalog_seeds (
  slug text primary key,
  name_ar text not null,
  emoji text not null,
  price_dinar bigint not null check (price_dinar >= 0),
  unlock_level integer not null check (unlock_level >= 1)
);

insert into public.catalog_seeds(slug,name_ar,emoji,price_dinar,unlock_level) values
('wheat','القمح','🌾',10000,1),('corn','الذرة','🌽',25000,3),
('carrot','الجزر','🥕',57000,5),('cucumber','الخيار','🥒',123000,7),
('tomato','الطماطم','🍅',257000,10),('potato','البطاطس','🥔',527000,14),
('lemon','الليمون','🍋',1300000,18),('apple','التفاح','🍎',2680000,25),
('orange','البرتقال','🍊',5560000,30),('grapes','العنب','🍇',11320000,37),
('strawberry','الفراولة','🍓',22950000,45),('blueberry','التوت','🫐',46200000,60),
('cherry','الكرز','🍒',135000000,75),('pineapple','الأناناس','🍍',340000000,100),
('coconut','جوز الهند','🥥',1000000000,120)
on conflict(slug) do update set name_ar=excluded.name_ar, emoji=excluded.emoji, price_dinar=excluded.price_dinar, unlock_level=excluded.unlock_level;

create table if not exists public.catalog_animals (
  slug text primary key,
  name_ar text not null,
  emoji text not null,
  price_dinar bigint not null check (price_dinar >= 0),
  productive boolean not null default true
);
insert into public.catalog_animals values
('chicken','الدجاج','🐓',100000,true),('cow','البقر','🐄',250000,true),
('sheep','الغنم','🐑',750000,true),('fish','السمك','🐟',1500000,true),
('birds','الطيور','🦅',2000000,true),('bees','النحل','🐝',1000000,true),
('cats','القطط','🐈',120000,false),('dogs','الكلاب','🦮',360000,false),
('horses','الخيول','🐎',950000,false)
on conflict(slug) do update set name_ar=excluded.name_ar, emoji=excluded.emoji, price_dinar=excluded.price_dinar, productive=excluded.productive;

create table if not exists public.inventory (
  owner_id uuid not null references public.profiles(id) on delete cascade,
  item_type text not null check (item_type in ('seed','crop','animal','tool','product')),
  item_slug text not null,
  quantity bigint not null default 0 check (quantity >= 0),
  updated_at timestamptz not null default now(),
  primary key(owner_id,item_type,item_slug)
);

create table if not exists public.friendships (
  id uuid primary key default gen_random_uuid(),
  requester_id uuid not null references public.profiles(id) on delete cascade,
  addressee_id uuid not null references public.profiles(id) on delete cascade,
  status text not null default 'pending' check (status in ('pending','accepted','blocked')),
  created_at timestamptz not null default now(),
  check (requester_id <> addressee_id),
  unique(requester_id,addressee_id)
);

create table if not exists public.farm_visits (
  id uuid primary key default gen_random_uuid(),
  visitor_id uuid not null references public.profiles(id) on delete cascade,
  farm_owner_id uuid not null references public.profiles(id) on delete cascade,
  visited_at timestamptz not null default now(),
  check (visitor_id <> farm_owner_id)
);

create table if not exists public.economy_transactions (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete cascade,
  currency text not null check (currency in ('dinar','premium')),
  amount bigint not null,
  reason text not null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.farms enable row level security;
alter table public.inventory enable row level security;
alter table public.friendships enable row level security;
alter table public.farm_visits enable row level security;
alter table public.economy_transactions enable row level security;
alter table public.catalog_seeds enable row level security;
alter table public.catalog_animals enable row level security;

create policy "profiles readable to authenticated" on public.profiles for select to authenticated using (true);
create policy "profile owner can update safe profile fields" on public.profiles for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);
create policy "public farms readable" on public.farms for select to authenticated using (is_public or owner_id = auth.uid());
create policy "owner can update own farm" on public.farms for update to authenticated using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy "owner can read own inventory" on public.inventory for select to authenticated using (owner_id = auth.uid());
create policy "owner can read own transactions" on public.economy_transactions for select to authenticated using (owner_id = auth.uid());
create policy "users can read own friendship rows" on public.friendships for select to authenticated using (requester_id = auth.uid() or addressee_id = auth.uid());
create policy "users can read visits involving them" on public.farm_visits for select to authenticated using (visitor_id = auth.uid() or farm_owner_id = auth.uid());
create policy "catalog seeds readable" on public.catalog_seeds for select to authenticated using (true);
create policy "catalog animals readable" on public.catalog_animals for select to authenticated using (true);

-- لا تمنح العميل صلاحية تعديل الرصيد أو المخزون مباشرة.
revoke insert, update, delete on public.economy_transactions from anon, authenticated;
revoke insert, update, delete on public.inventory from anon, authenticated;
revoke update on public.profiles from anon, authenticated;
grant select on public.profiles, public.farms, public.inventory, public.friendships, public.farm_visits, public.economy_transactions, public.catalog_seeds, public.catalog_animals to authenticated;

create or replace function public.buy_seed(p_slug text, p_quantity integer default 1)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  seed_row public.catalog_seeds%rowtype;
  player public.profiles%rowtype;
  total_cost bigint;
begin
  if uid is null then raise exception 'AUTH_REQUIRED'; end if;
  if p_quantity < 1 or p_quantity > 100 then raise exception 'INVALID_QUANTITY'; end if;

  select * into seed_row from public.catalog_seeds where slug = p_slug;
  if not found then raise exception 'SEED_NOT_FOUND'; end if;

  select * into player from public.profiles where id = uid for update;
  if not found then raise exception 'PROFILE_NOT_FOUND'; end if;
  if player.level < seed_row.unlock_level then raise exception 'LEVEL_TOO_LOW'; end if;

  total_cost := seed_row.price_dinar * p_quantity;
  if player.dinar < total_cost then raise exception 'INSUFFICIENT_FUNDS'; end if;

  update public.profiles set dinar = dinar - total_cost where id = uid;
  insert into public.inventory(owner_id,item_type,item_slug,quantity)
  values(uid,'seed',p_slug,p_quantity)
  on conflict(owner_id,item_type,item_slug)
  do update set quantity = public.inventory.quantity + excluded.quantity, updated_at = now();

  insert into public.economy_transactions(owner_id,currency,amount,reason,metadata)
  values(uid,'dinar',-total_cost,'buy_seed',jsonb_build_object('slug',p_slug,'quantity',p_quantity));

  return jsonb_build_object('ok',true,'quantity',p_quantity,'cost',total_cost);
end;
$$;

revoke all on function public.buy_seed(text,integer) from public;
grant execute on function public.buy_seed(text,integer) to authenticated;

-- إنشاء الملف الشخصي تلقائياً عند إنشاء حساب Auth؛ اسم المستخدم الافتراضي يحتاج تغييره لاحقاً.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  desired_username text;
begin
  desired_username := coalesce(new.raw_user_meta_data->>'username', 'farmer_' || substr(new.id::text,1,8));
  insert into public.profiles(id,username,display_name)
  values(new.id, desired_username, coalesce(new.raw_user_meta_data->>'display_name','مزارع جديد'))
  on conflict(id) do nothing;
  insert into public.farms(owner_id) values(new.id) on conflict(owner_id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();
