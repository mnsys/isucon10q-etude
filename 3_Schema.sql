
alter table estate add column d_popularity integer as (-popularity) stored;
create index estate_idx1 on estate (d_popularity asc, id asc);

alter table chair add column d_popularity integer as (-popularity) stored;
create index chair_idx1 on chair (d_popularity asc, id asc);
