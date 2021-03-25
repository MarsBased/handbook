# ActiveRecord guide

## Retrieving single records
There are three ways to retrieve a single record matching a certain criteria. The method to use depends on whether we want it to raise an exception if not found or if we want to find by the primary key or other attributes.

### Retrieve by primary key
Retrieving a record by primary key is the most common scenario. We generally do that in controller methods and background jobs.

If we want the retrieval to **raise an exception** we use `find`. Example:

```
Post.find(params[:id]) # Raises ActiveRecord::NotFound error if the record does not exist
```

We need to be careful when using this form as it can make a request crash. Normally we use this form in controller methods because we want the request to return a 404 Not Found error and in background jobs to retry the job. In any other case we should evaluate if it's really a good idea to raise an exception.

If we want the retrieval to **not raise an exception** we use `find_by`. Example:

```
Post.find_by(id: params[:id]) # Returns nil if the record does not exist
```

This is useful to handle cases when a record may or may not exist.

#### Performance
In any of the forms, since we are making a search by ID the query will always be fast (as long as the index on the primary key has not deliberately been deleted). So the performance of a query like this is always very good.

### Retrieve by other attributes
Retrieving a record by a non-primary key attribute is quite common. We may want to find a post by a slug, author, tag, etc. When more than one record match the condition, only the first one is returned (in general, it will be the most recent record).

If we want the retrieval to **raise an exception** we use `find_by!`. Example:

```
Post.find_by!(slug: params[:slug]) # Raises ActiveRecord::NotFound error if the record does not exist
```

Again, we need to be careful when using this form as it can cause a request to crash.

If we want the retrieval to **not raise an exception** we use `find_by`. Example:

```
Post.find_by(slug: params[:slug]) # Returns nil if the record does not exist
```

#### Performance
By default a query on a table by a condition needs to scan **all records** on the table in order to filter them. This is OK for small tables like settings-like tables that have the order of 100 records, but it starts to get slower with more than that.

In order to make these queries fast we need to have **an index** on the combination of attributes we want to retrive by or at least some of them. The best way to know if an index works for a query is to `EXPLAIN` the query and check if it uses the index or not.

## Retrieving multiple records
When retrieving a list of records from the database the **most important** thing to always take into account is how many records we are requesting. If we ask for too many records to the database the query will be very slow, it will consume a huge amount of memory and the treatment in Ruby will be slow too.

If not careful **a whole application can be taken down by a single query requesting too much data**.

To retrieve a list of records from the database we use `where`. Example:

```
Post.where(category: params[:category]).limit(50)
```

When doing a query like this in the context of a web request we need to always limit the returned results by using `limit`. Usually this is done with a pagination library. But if there is no pagination involved we still need to limit the query to a reasonable number.

When we absolutely need to retrieve a large number of records to treat them we need to use `find_each` and ideally do it outside of a request to avoid having a high response time and a potential (highly probable) timeout. Usually we would do it in a background job. The `find_each` method asks for all the records to the database in batches of 1000 by default (it can be configured with the `batch_size` option, like: `find_each(batch_size: 100)`), so that the database load is kept constant and only a limited number of records are retrieved every time. This also controlls memory as only N number of records are kept in memory at a time.

Example:

```
Post.where(created_at: 1.day.ago).find_each do |post|
   post.destroy
end
```

**It's absolutely forbidden to use `all` in any context.** For example: `Post.all`. The only exception is we know 100% sure that a table will always have a very limited set of records.

### Scopes and query execution
It's crucial to understand when a query is executed by Rails and how we can control it. To put it simply: **a query is not executed until its data is needed**.

It's very hard to list all the possible ways when this happens, but these are the most common:

* The results of the query need to be printed to stdout (when using a rails console, for example).
* The results of the query need to be shown in the page.
* An Enumerable method is called on the query to perform some treatment or transformation on the data.
* An aggregation method like `count`, `min` or `max` is called.

The best way to see when a particular expressions gets executed and how is to look at the log and see the exact query that gets sent to the database.

#### Examples

If we have a console session open and we do `Post.where(created_at: 1.day.ago)` it will immediately execute the query since the console will request the results to be printed.

If we have in a controller a query like `@posts = Post.where(created_at: 1.day.ago)`, it won't be executed at this time. If we then do this in the view: `@posts.each do |post| ... end` it will execute the query at that time to be able to iterate over the records.

In a controller we can do something like this:

```
def index
  @posts = Post.where(created_at: 1.day.ago)
  filter_posts
end

def filter_posts
  @posts = @posts.where(author: params[:author]) if params[:author]
  @posts = @posts.publishd if params[:published]
end
```

The query will be created incrementally but executed **only once** combining all conditions once the data is requested (usually in the view).

If we do something like this:

```
def index
   @posts = Post.where(created_at: 1.day.ago)
   @posts = @posts.map do |post| # Executes the query!
     ...
   end
end
```

This will execute the query in order to do the `map` becauase the `map` method needs to have the values in order to transform them.

### Performance
The argument is similar to finding a record by a non-primary key attribute. By default a query to retrieve a list of results will need to scan through all the table. These queries can be improved by having indexes on the filtered attributes.

## Joining tables
A common technique used to build more complex queries is to join various tables together through their associations. This allows to filter a table by an attribute of an associated table, order by that attribute, etc.

To join tables we use the `joins` method. Example:

```
Post.joins(:author)
```

We can use attributes from the joined table to filter the query or order it. Examples:

```
Post.joins(:author).where(authors: { gender: :female })
Post.joins(:author).order(birth_date: :desc)
```

Note that inside the where and order clauses we use `authors` (plural). This is because we need to specify the name of the table instead of the association. This is also relevant when using custom association names in which the name of the association is different than the name of the table. An example:

```
class User; end
class Post
   belongs_to :author, class_name: 'User'

   scope :from_female_authors ->() { joins(:author).where(users: { gender: :female })
end
```

Joins can traverse as many tables as we want by nesting hashes inside hashes. For example:

```
Post.joins(author: { address: :city }).where(cities: { country: 'ES' }) # Post -> Author -> Address -> City
```

Often, though, these queries can be simplified why using `has_many through:` associations in the model which end up producing the same queries.

### How joining works at the database level
At a high level a join between table A and table B works like this:

1. It creates a new *virtual table* combining all the columns of table A and all the columns of table B.
2. For every record in table A it takes all the records in table B that match the `ON` criteria. By default this matches the primary key of table B with the association foreign key in table A. For each matched record in B it adds a new row to the *virtual table* with the values of the record in A and the values of the record in B.

It's much easier to see with an example:

Say we have the Post table with the `title` and `author_id` columns, and the Author table with the `name` and `gender` columns.

Posts has the following data:

```
id|title      |author_id
1 |Hello World|1
2 |Bye World  |2
3 |Ruby World |2
```

Authors has the following data:

```
id|name  |gender
1 |Rocky |male
2 |Adrian|female
```

Running `Post.joins(:author).where(authors: { gender: :female }` will produce the following SQL:

```
SELECT * FROM posts INNER JOIN authors ON posts.author_id = authors.id WHERE authors.gender = 'female'
```

Which will create the following virtual relation as a result:

```
posts.id|posts.title|posts.author_id|authors.id|authors.name|authors.gender
2       |Bye World  |2              |2         |Adrian      |female
3       |Ruby World |2              |2         |Adrian      |female
```

Another example: `Author.joins(:posts)` will produce:

```
SELECT * FROM authors INNER JOIN posts ON authors.id = posts.author_id
```

Which will create the following virtual relation as a result:

```
authors.id|authors.name|authors.gender|posts.id|posts.title|posts.author_id
1         |Rocky       |male          |1       |Hello World|1
2         |Adrian      |female        |2       |Bye World  |2              
2         |Adrian      |female        |3       |Ruby World  |2              
```

### Handling repeated values
A common pitfall when working with joins is forgetting to call distinct to remove duplicate values.

Continuing with the example above, suppose we want to get all authors that have posts in the ruby category. We can write this query: `Author.joins(:posts).where(posts: { category: :ruby })`.

However if we iterate on the results of this query we will find that authors are duplicated **when the author has more than one post in the ruby category**. Specifically every author will appear N times, where N is the number of ruby posts of the author.

To remove duplicates we need to call `distinct`. Example: `Author.joins(:posts).where(posts: { category: :ruby }).distinct`

Note that this only happens when joining on a `has_many` association, because for `belongs_to` and `has_one` there is always only one (at most) matching record in the joined table.

## Avoiding N+1 queries

It is very easy to introduce N+1 queries when listing records. Example:

```
@posts = Posts.published.limit(50)
@posts.each do |post|
  puts post.author.name
end
```

This will run a query to get all the posts from the database and then, for each post, it will run another query to load the author from the database, for a total of 51 queries.

We can usually use `includes` to avoid the problem. Following the example we could fix the problem by changing the query to `@posts = Posts.published.includes(:author).limit(50)`.

Doing it this way, Rails will only run 2 queries: one to get all the posts and one to get all the authors (by combining the author_id of each post in a single query).

### Complex N+1 queries

There are times where is not as easy as adding an includes, for example when adding conditions to the associated models. Example:

```
@authors = Author.all.limit(50)
@authors.each do |author|
  post = @author.posts.published.first
  post.title
end
```

In this example we want to only load published posts for each author, instead of all posts. In order to remove the N+1 query in this scenario we can define a different association in the model with a scope, like this:

```
class Author < ApplicationRecord
  has_many :published_posts, -> { published }, class_name: 'Post', inverse_of: :author
end
```

And now we can use `includes` as normal with this association:

```
@authors = Author.includes(:published_posts).limit(50)
@authors.each do |author|
  post = @author.published_posts.first
  post.title
end
```

Note that in the loop we need to use `@author.published_posts`. If we use `@author.posts.published` it will still trigger the N+1 queries, because Active Record will treat it as a different set of records (Active Record does not know that `published_posts` is the same as `posts.published`).

## Aggregation functions

We need to be careful when running queries that include aggregation functions because these are very hard (often impossible) to optimize by the database engine and often require a full scan of the table.

Running an aggregation function, specially a count, on a big table can have a considerable negative impact on the performance of an application.

When running aggregation queries it should always be by adding conditions that limit the scope of the results, so the full scan only needs to be done from the returned results.

Protip: Use `size` instead of `count` unless you are doing a direct count on a table. Using `count` always triggers a query while using `size` is able to use the cached values of a previous query. Example: `Post.published.size` instead of `Post.published.count`.
