create schema 20200331_db;
use 20200331_db;

# 1. table design

create table users
(
    id        int primary key auto_increment,
    username  varchar(30) not null unique,
    password  varchar(30) not null,
    email     varchar(50) not null,
    gender    char(1)     not null,
    age       int         not null,
    job_title varchar(40) not null,
    ip        varchar(30) not null
);

create table addresses
(
    id      int primary key auto_increment,
    address varchar(30) not null,
    town    varchar(30) not null,
    country varchar(30) not null,
    user_id int         not null,
    constraint fk_addresses_users
        foreign key (user_id)
            references users (id)
);

create table photos
(
    id          int primary key auto_increment,
    description text     not null,
    date        datetime not null,
    views       int      not null
);

create table comments
(
    id       int primary key auto_increment,
    comment  varchar(255) not null,
    date     datetime     not null,
    photo_id int          not null,
    constraint fk_comments_photos
        foreign key (photo_id)
            references photos (id)
);

create table users_photos
(
    user_id  int not null,
    photo_id int not null,
    primary key (user_id, photo_id),
    constraint fk_up_users
        foreign key (user_id)
            references users (id),
    constraint fk_users_photos
        foreign key (photo_id)
            references photos (id)
);

create table likes
(
    id       int primary key auto_increment,
    photo_id int,
    user_id  int,
    constraint fk_likes_users
        foreign key (user_id)
            references users (id),
    constraint fk_likes_photos
        foreign key (photo_id)
            references photos (id)
);

# 2. insert
insert into addresses(address, town, country, user_id)
select u.username, u.password, u.ip, u.age
from users u
where u.gender = 'M';

# 3. update
update addresses a
set a.country =
        case
            when a.country like 'B%' then 'Blocked'
            when a.country like 'T%' then 'Test'
            when a.country like 'P%' then 'In Progress'
            end;

# 4. delete
delete
from addresses
where id % 3 = 0;

# 5. users
select username, gender, age
from users
order by age desc, username;

# 06.	Extract 5 Most Commented Photos
select p.id,
       p.date                                                date_and_time,
       p.description,
       (select count(*) from comments where photo_id = p.id) commentsCount
from photos p
order by commentsCount desc, id
limit 5;

# 07.	Lucky Users
select concat_ws(' ', u.id, u.username) id_username, u.email
from users u
         join users_photos up on u.id = up.user_id
where up.user_id = up.photo_id
order by u.id;

# 08.	Count Likes and Comments
select p.id as photo_id,
       (
           select count(photo_id)
           from likes
           where p.id = photo_id
       )       likes_count,
       (
           select count(id)
           from comments
           where photo_id = p.id
       )       comments_count
from photos p
order by likes_count desc, comments_count desc, p.id desc;

# 09.	The Photo on the Tenth Day of the Month
select concat(left(p.description, 30), '...') summary,
       p.date
from photos p
where day(p.date) = 10
order by p.date desc;

# 10.	Get User’s Photos Count
create function udf_users_photos_count(username VARCHAR(30))
    returns int
    deterministic
begin
    return (
        select count(up.photo_id)
        from users u
                 join users_photos up on u.id = up.user_id
        where u.username = username
    );
end;

SELECT udf_users_photos_count('ssantryd') AS photosCount;
# 2

# 11.	Increase User Age
create procedure udp_modify_user(user_address varchar(30), user_town varchar(30))
    deterministic
begin
    update users u join addresses a on u.id = a.user_id
    set u.age = u.age + 10
    where a.address = user_address
      and a.town = user_town;
end;

CALL udp_modify_user ('97 Valley Edge Parkway', 'DivinГіpolis');
SELECT u.username, u.email,u.gender,u.age,u.job_title FROM users AS u
WHERE u.username = 'eblagden21';
