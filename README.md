# Labook-api
API to store and retrieve confidential development files (configuration, credentials)

## Post
| post_id | GPA | ori_school | ori_department | school_department | lab_score | professor_attitude |content|
| -------- | -------- | -------- | -------- | -------- | -------- | -------- | --- |
| String | int     | String     | String    | String   | String | String | String |

lab_score : (1~5)
professor_attitude : adjective

## Routes
All routes return Json

- GET `/` : Root route shows if Web API is running
- GET `api/v1/posts/` : returns all confiugration IDs
- GET `api/v1/posts/[post_id]` : returns details about a single post with given ID
- POST `api/v1/posts/` : creates a new post

## Test POST
```console
http -v --json POST localhost:9292/api/v1/posts \
gpa="4.1" \
ori_school="NTHU" \
ori_department="EE" \
school_department="CS" \
lab_score="5" \
professor_attitude="Nice" \
content="老師人很好，對我們都像兒子XD，動不動就請吃食物"
```

## Install
Install this API by cloning the relevant branch and installing required gems from Gemfile.lock:

```
bundle install
```

## Test
Run the test script:

```
ruby spec/api_spec.rb
```

## Execute
Run this API using:

```
rackup
```