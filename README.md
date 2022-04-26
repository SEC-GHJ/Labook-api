# Labook-api
API to store and retrieve confidential development files (configuration, credentials)

## Accounts
| account_id | GPA | ori_school | ori_department | account | password |
| ------- | ------ | --- | --------- | ------------------ | ------- |
| String  | int |  String  | String    | String   | String  |

## Posts
| post_id | lab_id | poster_id | lab_score_secure | professor_attitude_secure | content_secure |
| ------- | ------ | --- | --------- | ------------------ | ------- |
| String  | String |  String  | int    | String   | String  |

**Encrypted columns: ()_secure**

**Foreign Key:** lab_id

lab_score : (1~5)
professor_attitude : adjective

## Labs
| lab_id | lab_name | school | department | professor |
| -------- | -------- | -------- | -------- |-------- |
| String | String | String | String | String |

## Chats
| chat_id | sender_name | reciever_id | content | 
| -------- | -------- | -------- | -------- |
| String | String | String | String |
**Foreign Key:** sender_name, reciever_id
primary key : chat_id

## Routes
All routes return Json

- GET `/` : Root route shows if Web API is running
- GET `api/v1/labs/[lab_id]/posts/[post_id]`: returns details about a single post with given ID
- GET `api/v1/labs/[lab_id]/posts/` : returns all posts for a lab
- POST `api/v1/labs/[lab_id]/posts/`:  create a post for a lab
- GET `api/v1/labs/[lab_id]` : Get information about a lab
- GET `api/v1/labs` : Get list of all projects
- POST `api/v1/labs/` : create a new lab

## Test POST
```console
http -v --json POST localhost:9292/api/v1/labs \
lab_name="AbcLab" \
school="NTHU" \
department="EE" \
professor="Mr. Abc"

http -v --json POST localhost:9292/api/v1/labs/1/posts \
lab_score="5" \
professor_attitude="Nice" \
content="老師人很好，對我們都像兒子XD，動不動就請吃食物" \
user_id="1"
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
```

## Test
Setup test database once:

```
RACK_ENV=test rake db:migrate
```

Run the test script:
```
bundle exec rake spec
```

## set environment

```
RACK_ENV=development
echo $RACK_ENV
unset RACK_ENV
```