# How to blog, according to MarsBased

At MarsBased, we are always learning new stuff. Running your own company means being constantly in the loop of learning things you could have never predicted you would ever need. Among other stuff, we have learnt how to run a blog.

Here's a thing or two we have learnt along the way.

### Choose a good title

Let's start off from the very beginning: the title. Nowadays titles do not only have to be understandable by humans, but by robots too. And while we don't refer to robots like [this one](http://static.guim.co.uk/sys-images/Guardian/Pix/pictures/2014/2/21/1392977241047/Robot-from-The-Terminator-010.jpg "Robot") or [this one](http://img4.wikia.nocookie.net/__cb20141005032524/deadliestfiction/images/e/eb/Optimus_Prime_Generation_1.jpg "Robot"), it's always a good idea to let Google bots and the rest of web crawlers "understand" that title.

Therefore, if you're writing a guide on how to craft good blog posts you might want to go with "*How To Craft Good Posts For Your Blog*" or "*10 Useful Tips For Writing a Blog*". Choosing a title like "*Disentangling the Unfathomable Nature of Swordbuckling in the Interwebs*" probably won't get you very far.

Titles should be meaningful, just like the first sentence of the post. [Readers absorb the first and last three words of a sentence](https://blog.bufferapp.com/headline-formulas?utm_content=buffer144c3&utm_medium=social&utm_source=marsbased.com&utm_campaign=marsbased "Buffer blog"), so make them count. Also, avoid clickbait titles ("*I Unboxed My iPhone and I Couldn't Believe What Happened Next*") where possible. They're not worth it: they might earn you a thousand followers today, but all will be gone tomorrow if you don't deliver what's promised.

Once you've got your title, make sure you capitalise accordingly by using [Title Capitalization](http://titlecapitalization.com/), selecting the Chicago Style Manual.

Last, but not least, titles should include your keywords. If you're blogging about gadgets, include the words *wearables*, *tech*, *smartphones*, *gadgets*, etc. This will help SEO and thus increase your blog's visibility. Ideally, post titles [shouldn't exceed 60 characters](http://www.orbitmedia.com/blog/ideal-blog-post-length/ "Marketing tips").

### Catch your reader's attention

The first sentences of a post are crucial. As we stated before, they really do count to make a good impression and make clear what is the post about. They usually are the ones before the "Read more" button.

Moreover, the first sentences of a post count a lot for SEO, just like titles do. Some search engines will also index a snippet of the text, and that will be the first sentences. Also, when you share a blog post to Twitter or Facebook, a snippet of the text is included. Make the most out of it: keywords, facts & figures, a shocking anecdote...

However, just like titles, the first sentences must be an open invite to click on the post and continue reading, while clickbait is strongly discouraged.

### Content

Nowadays, the definition of good content is, as Guy Kawasaki put it, "[content worth sharing](https://www.startupgrind.com/events/details/startup-grind-london-hosted-guy-kawasaki-canvaex-apple#/ "Startup Grind hosts Guy Kawasaki")".

We can't emphasize enough how important a blog is for SEO. A blog allows you to have original content (yay!), on a regular basis (double yay!) that can be commented on and shared, and therefore spread through the web (triple yay!).

As a result, your company name will be spread throughout the web if you do it right. Choose your keywords wisely (don't overbloat it, though!) and make it worth sharing. Then, your readers will do the work for you.

One interesting tip: if you talk about companies or individuals in your post, it's a good idea to link to their website. For the extra points, you can mention them on social networks and maybe earn some extra retweets/likes/shares.

### Link

Back in the early days of the Internet, backlinking was a good idea. Back then, blogs and sites alike paid one another to have a link to their site, whatever the content was, just to pass onto one another visitors and page rank.

Nowadays, the reality is very different. [Google penalises that](http://white.net/blog/high-risk-seo-33-ways-to-get-penalised-by-google/ "Google Penalises Backlinks").

We don't have a dog in the fight, but we like to link other sites if we mention them. Not only to reference a quote, give other people credit, or also to help the reader find more interesting stuff outside of our blog.

It is worth noting that you don't want your users to leave your page for good, so instead of adding a regular link to ease the transition from your blog post to an external website, just add the *target=_blank* HTML attribute so that the new page opens in a new tab.

It is likewise important to add a good title attribute to your link, to help crawlers and users alike to understand the nature of the link. In this case, if we want to link to [Buffer's blog](http://blog.buffer.com "Buffer's blog"), we'll do it like this:

    <a href="http://blog.buffer.com" title="Buffer's Blog" target="_blank">Read Buffer's Blog</a>

One of our favourite bloggers, [John Rampton](http://www.johnrampton.com/ "John Rampton website"), who writes kickass posts for [Entrepreneur.com](http://www.entrepreneur.com/ "Entrepreneur-com") and [Forbes](http://www.forbes.com/ "Forbes") told us to use the first three links of a blog post to link your previous posts when possible. We didn't find it suitable for this post, but most of the time it can fit in pretty well and will encourage newcomers to your blog to read your previous articles.

### Images

Each blog post needs to have at least one image. Do not skip this part, ever.

Images help readability and can help better explain a concept. Remember that "A picture is worth a thousand words". Good examples of this are: a good infography, a picture of the crowded event you hosted or a nice shot of your new offices.

Images will also be fetched by RSS feeds and the sharing widgets of your favourite social networks, so make sure it's well displayed there. As a matter of fact, Tweets and Facebook posts with images receive more engagement, [according to Buffer](https://blog.bufferapp.com/twitter-images "Buffer's blog").

On the tech side, images need to have their *alt* and *title* attributes being as descriptive as possible. This will ultimately reflect on your SEO. Here's an example:

    <img src="http://route.to/image" alt="A group shot of the MarsBased team" title="A group shot of the MarsBased team">
    
### Tags

Each post should be categorised using tags. Currently, at MarsBased, we're using these ones:

* __MarsBased__: For general purpose company updates.
* __Entrepreneurship__: When talking about entrepreneurship as a concept.
* __News__: For news-like blog posts, whether ours or our clients'.
* __Rails__: If the post is about Rails. Applies to other technologies: __Angular__, __Node.js__, __Ionic__, __Ruby__, __CSS__, __HTML__, __API__, etc.
* __Naiz__: Whenever we want to blog about a client, we have to do it using their tag.
* __Lessons Learnt__: For lessons learnt-like blog posts.
* __Business__: Self-explanatory. Same as __Productivity__, __Management__, __Sales__, __Marketing__, __Development__, etc.
* __Startup Grind__: For Startup Grind posts.
* __Remote__: For blog posts about remote work, such as best practices, DOs and DON'Ts, etc.
* __Collaborative Post__: For those posts where it's all faces and shit. The fun ones.
* __Guides__: For all these guides and How To blogs.

There's no fixed number. Tags should be used, not abused, and should be all starting with a Capital letter.


### Readability

Use subtitles to distribute the reading rhythm throughout the post. One long post with no subtitles is harder to follow; whereas a well-structured blog post with evenly divided sub-sections will help to maintain the reader's focus.

Subtitles, when correctly marked using `<h2>` and `<h3>` tags, help crawlers index the page's content much better.

### Style

The perfect blog post length is thought to be [around 1200 words](http://www.bitrebels.com/social/makes-perfect-blog-post-infographic/ "Infographic about blogging").

It is very important that you double-check your post thoroughly for typos, broken links, unformatted parts or unreferenced quotes. Mediocre or poorly processed posts seldom get shared. We use [Grammarly](https://app.grammarly.com/) for this.

In this last case, remember what was the last blog post you read and thought "I'm going to share this one". Why did you do it? Was it the pictures? Was it funny? Was it because someone important wrote it? No. Most of the time you share it because you feel like more people should read it, and you either send it to specific people or you spread it on the web by sharing it through Twitter, Facebook or your social networks of choice.

It is a good idea to re-read the post 3 o 4 times prior to publishing, and it's even more advisable to ask your team or another person to read it. What's obvious to you, it might not be for everyone. A concept might need further explanation, some typos go unnoticed by spell-checkers (*your* vs. *you're*, *then* vs *than*) or you might have left a sentence unfinished (these things happen, but at MarsBased we alwa

### Call to action

Finally, the post should have a *raison d'être*: it can be an informative post, a how-to guide, an opinion to give food for thought, or an invitation to the new beta version of your product.

Whatever the aim of the post is, it should conclude with a call to action. A call to action (often referred to as CTA) is an instruction to the audience to provoke an immediate response, usually using an imperative verb such as "call now", "find out more" or "visit a store today" ([source](http://homebusiness.about.com/od/homebusinessglossar1/g/Call-To-Action-Definition.htm "Definition of call to action")). If you don't know what call to action you should do, the message of your post might not be clear enough, yet you can always ask the audience to share the post around.
