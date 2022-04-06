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