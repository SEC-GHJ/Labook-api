# Labook-api
API to store and retrieve confidential development files (configuration, credentials)

## Database schema
![](https://i.imgur.com/OEzAQnL.png)

## Accounts
| account_id | GPA | ori_school | ori_department | username | nickname | password | line_access_token_secure
| ---------- | --- | ---------- | -------------- | ------- | -------- |
| Integer     | String | String     | String    | String  | String   | String   | String |

## Labs
| lab_id | lab_name | school | department | professor |
| ------ | -------- | ------ | ---------- | --------- |
| Integer | String   | String | String     | String    |

**Encrypted columns: ()_secure**
**Foreign Key:** lab_id, poster_id

lab_score : (1~5)
professor_attitude : adjective


## Posts
| post_id | lab_id | poster_id | lab_score_secure | professor_attitude_secure | content_secure |  accept_mail   | vote_sum |
| ------- | ------ | --------- | --------- | ------------------ | ------- | --- | ---- |
| Integer  | Integer | Integer    | String       | String             | String  |   Integer  | Integer  |

## Chats
| chat_id | sender_id | receiver_id | content_secure |
| ------- | --------- | ---------- | ------- |
| Integer  | String    | String     | String  |

**Encrypted columns: ()_secure**
**Foreign Key:** sender_id, receiver_id
primary key : chat_id

## Votes
| vote_id | voter_id | voted_post_id | number |
| ------- | --------- | ---------- | ------- |
| Integer  | Integer    | Integer     | Integer  |


## Routes
All routes return Json
- GET `/` : Root route shows if Web API is running

### `api/v1/posts` (warning: anyone can know the poster_id & commenter_id)
- GET `api/v1/posts`: return all posts
- GET `api/v1/posts/[post_id]`: returns details about a single post, including policies and votes of given bearer `auth_token`
- POST `api/v1/posts/[post_id]/votes`: create or update a vote for a post for the account of given bearer `auth_token`
- POST `api/v1/posts/[post_id]/comments`: create a comment for a post for the account of given bearer `auth_token` 
- GET `api/v1/posts/me`: return all posts of the account of given bearer `auth_token`

### `api/v1/comments`
- POST `api/v1/comments/[comment_id]/votes`: create or update a vote for a comment for the account of given bearer `auth_token`

### `api/v1/accounts`
- POST `api/v1/accounts`: create an account **(warning: anyone who know the api addr can create account)**
- GET `api/v1/accounts/[account_id]`: return policies from the account of given bearer `auth_token` to the account of `account_id`
- ~~GET `api/v1/accounts/[account_id]/posts`: return all posts for an account~~
- ~~GET `api/v1/accounts/[account_id]/votes`: return all votes for an account~~
- GET `api/v1/accounts/[account_id]/contact`: get or create chatroom for an account from the account of given bearer `auth_token`
- PATCH `api/v1/accounts/setting`: update account setting for accept_mail & show_all, return new account or 204 (no update)

### `api/v1/auth`
- POST `api/v1/auth/authenticate`: return an auth token if login success
- POST `api/v1/auth/register`: return an result if register success
- POST `api/v1/auth/line_sso`: 
- POST `api/v1/auth/line_notify_sso`: 

### `api/v1/labs`
- GET `api/v1/labs` : Get list of all labs
- POST `api/v1/labs` : create a new lab **(warning: anyone who know the api addr can create lab)**
- GET `api/v1/labs/[lab_id]` : Get information about a labs
- GET `api/v1/labs/[lab_id]/posts` : returns all posts for a lab **(warning: everyone can know the poster_id & commenter_id)**
- POST `api/v1/labs/[lab_id]/posts`:  create a post for a lab for the account of given bearer `auth_token`
- ~~GET `api/v1/labs/[lab_id]/posts/[post_id]`: returns details about a single post with given ID~~
- ~~POST `api/v1/labs/[lab_id]/posts/[post_id]/votes`: create or update a vote about a single post with given ID~~

### `api/v1/chats`
- POST `api/v1/chats/[account_id]` : create a new chat with account_id for the account of given bearer `auth_token`
- GET `api/v1/chats/[account_id]`: Get all messages with account_id for the account of given bearer `auth_token`
- GET `api/v1/chats`: Get all chatrooms for the account of given bearer `auth_token`

## Test POST Examples
```console
# create a new account
http -v --json POST localhost:3000/api/v1/accounts \
username="testacc" \
nickname="新竹強尼戴補" \
gpa="123" \
ori_school="IDK" \
ori_department="CS" \
password="123456" \
email="abc@gmail.com" \
show_all="1" \
accept_mail="0"

# login
http -v --json POST localhost:3000/api/v1/auth/authenticate \
username="testacc" \
password="123456"

# create a new lab
http -v --json POST localhost:3000/api/v1/labs \
lab_name="AbcLab" \
school="NTHU" \
department="EE" \
professor="Mr. Abc"

# create a new post
http -v --json POST localhost:3000/api/v1/labs/[lab_uuid]/posts \
'Authorization: Bearer {token}' \
lab_score="5" \
professor_attitude="Nice" \
content="老師人很好，對我們都像兒子XD，動不動就請吃食物" \
vote_sum="0"

# create a new vote for the post
http -v --json POST localhost:3000/api/v1/posts/[post_uuid]/votes \
'Authorization: Bearer {token}' \
number="1"

# create a new comment for the post
http -v --json POST localhost:3000/api/v1/posts/[post_uuid]/comments \
'Authorization: Bearer {token}' \
content="這是留言 of 老師人很好，對我們都像兒子XD，動不動就請吃食物" \
vote_sum="0"

# create a new vote for the comment
http -v --json POST localhost:3000/api/v1/comments/[comment_id]/votes \
'Authorization: Bearer {token}' \
number="-1"

# create a new chatroom with `account_uuid`
http -v --json POST localhost:3000/api/v1/accounts/[account_uuid]/contact \
'Authorization: Bearer {token}'

# create a new chat with `account_uuid`
http -v --json POST localhost:3000/api/v1/chats/[account_uuid] \
'Authorization: Bearer {token}' \
content="chat with testing"

# update account setting
http -v --json POST localhost:3000/api/v1/accounts/setting \
'Authorization: Bearer {token}' \
accept_mail="1" \
show_all="0"

```

## Install
Install this API by cloning the relevant branch and installing required gems from Gemfile.lock:

```
bundle install
```
Setup development database once:

```
bundle exec rake db:migrate
```

## Execute
Run this API using:

```
bundle exec rackup
bundle exec run:dev
```

## Test
Setup test database first:

```
RACK_ENV=test rake db:migrate
```

Then, we run the test script:
```
bundle exec rake spec
```

## set environment
```
RACK_ENV=development
echo $RACK_ENV
unset RACK_ENV
```