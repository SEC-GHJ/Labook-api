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
### `api/v1/posts`
- GET `api/v1/posts`: return all posts
- GET `api/v1/posts/[post_id]`: returns details about a single post
### `api/v1/accounts`
- POST `api/v1/accounts`: create an account
- GET `api/v1/accounts/[account_id]`: return an account info
- GET `api/v1/accounts/[account_id]/posts`: return all posts for an account
- GET `api/v1/accounts/[account_id]/votes`: return all votes for an account
- GET `api/v1/accounts/[account_id]/contact`: get or create chatroom for an account
### `api/v1/auth`
- POST `api/v1/auth/authenticate`: return an auth token if login success
- POST `api/v1/auth/register`: return an result if register success
### `api/v1/labs`
- GET `api/v1/labs` : Get list of all labs
- POST `api/v1/labs` : create a new lab
- GET `api/v1/labs/[lab_id]` : Get information about a labs
- GET `api/v1/labs/[lab_id]/posts` : returns all posts for a lab
- POST `api/v1/labs/[lab_id]/posts`:  create a post for a lab
- GET `api/v1/labs/[lab_id]/posts/[post_id]`: returns details about a single post with given ID
- POST `api/v1/labs/[lab_id]/posts/[post_id]/votes`: create or update a vote about a single post with given ID

### `api/v1/chats`
- POST `api/v1/chats/[account_id]` : create a new chat with account_id
- GET `api/v1/chats/[account_id]`: Get all messages with account_id
- GET `api/v1/chats`: Get all chatrooms for account.

## Test POST
```console
http -v --json POST localhost:3000/api/v1/accounts \
username="testacc" \
nickname="新竹強尼戴補" \
gpa="123" \
ori_school="IDK" \
ori_department="CS" \
password="123456" \
email="abc@gmail.com"

http -v --json POST localhost:3000/api/v1/auth/authenticate \
username="testacc" \
password="123456"

http -v --json POST localhost:3000/api/v1/labs \
lab_name="AbcLab" \
school="NTHU" \
department="EE" \
professor="Mr. Abc"

http -v --json POST localhost:3000/api/v1/labs/1/posts \
poster_account="a3" \
lab_score="5" \
professor_attitude="Nice" \
content="老師人很好，對我們都像兒子XD，動不動就請吃食物" \
accept_mail="1" \
vote_sum="0"

http -v --json POST localhost:3000/api/v1/labs/1/posts/[post_uuid]/votes \
voter_account="a1" \
number="-1"

http -v --json GET localhost:3000/api/v1/posts/me 'Authorization: Bearer {token}'

http -v --json GET localhost:3000/api/v1/accounts/a1/contact 'Authorization: Bearer {token}'

http -v --json POST localhost:3000/api/v1/chats/a1 content="chat with testing" 'Authorization: Bearer {token}'

http -v --json GET localhost:3000/api/v1/chats 'Authorization: Bearer {token}'

http -v --json GET localhost:3000/api/v1/chats/a1 'Authorization: Bearer {token}'
```
## Test logger
```
http -v GET localhost:9292
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