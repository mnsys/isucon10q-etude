
alter table estate add column d_popularity integer as (-popularity) stored;
create index estate_idx1 on estate (d_popularity asc, id asc);
create index estate_idx2 on estate (latitude);
create index estate_idx3 on estate (longitude);

alter table chair add column d_popularity integer as (-popularity) stored;
create index chair_idx1 on chair (d_popularity asc, id asc);
