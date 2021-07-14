# The MarsBased SEO Guidelines

As a development consultancy, we get the chance to work on very different products and projects. From all of them, we learn something new, but in all of them, we apply our previous knowledge.

With dozens of different projects in well over five years, we've compiled our SEO 101 that we apply to all our projects.

# Tools

Before getting into detail, here are the tools that you will need.

## Google Search Console (previously known as Google Webmaster Tools)

<strong>URL:</strong> <a href="https://search.google.com/search-console" title="Google Search Console" target="_blank">https://search.google.com/search-console</a>

<strong>Description:</strong> Google Search Console is a Google service to list and manage your domains. From domain verification to keyword analysis, this is a very useful tool. Amongst other things, you can verify the schema.org data, the robots.txt file and the sitemap structure.

We will use the Search Console to add all variants of the same domain, in order to claim and verify them:

* http://marsbased.com
* http://www.marsbased.com
* https://marsbased.com
* https://www.marsbased.com

We will also check for errors here: 404s, performance errors, robots.txt not found, sitemap errors, etc. This is a most powerful tool and we recommend taking your time to explore it.

<strong>If, and only if, the site includes search</strong> and has got therefore search parameters in the URL, this needs to be configured. Here’s a <a href="https://support.google.com/webmasters/answer/6080550?hl=en" title="Google guide to set up search parameters" target="_blank">good guide to help you to set up the search parameters</a>. Typically, Google will figure it out automatically, and it’ll be right in 80% of the cases, which is good enough. Don’t waste too much time with this.

## Google Analytics

<strong>URL:</strong> <a href="http://www.google.com/analytics" title="Google Analytics" target="_blank">http://www.google.com/analytics</a>

<strong>Description:</strong> Google Analytics is <i>THE</i> tool when it comes to analysing user behaviour on a given site. It tracks every visitor down, from where they come from, what do they do on the site, and where do they go when they leave. Analytics does also allow you to create marketing campaigns, among other capabilities.

Google Analytics will provide you with the Google Analytics tracking code, which you will find in the Admin tab. This is what you will implement in every project inside the `<head>` HTML tag.

If you're a developer, you probably don't need anything else from Google Analytics. If you're a marketer, you're better off studying and testing it already!

### The Sitemap

The sitemap is typically an XML file that describes the structure of your site, and it’s placed at the root of the project. Sitemaps follow a convention that you can find in the <a href="https://en.wikipedia.org/wiki/Sitemaps" title="Wikipedia article on Sitemaps" target="_blank">Wikipedia entry about the Sitemaps files</a>.

Normally, sitemaps can hold up to 50k URLs, but it’s advisable to split them into smaller sitemaps that link each other. Most indexers recognize also zipped sitemaps.

Here’s <a href="https://marsbased.com/sitemap.xml" title="MarsBased sitemap" target="_blank">the sitemap file for our website</a>, for example.

You can test the structure of your sitemap using Google Search Console.

You can even submit it from there. But most indexers will either look at <i>www.site.com/sitemap.xml</i> or else read the sitemap location from the robots.txt file, where you can also specify it. We will see this in the next section!

If you encounter any errors, here’s <a href="https://support.google.com/webmasters/answer/35738?hl=en" title="Common mistakes in sitemaps files" target="_blank">a list of the most common errors when creating sitemaps</a>.

### Robots.txt

Robots.txt is a file we use to tell all crawlers how to behave when crawling a site. It is located at the root level (<i>www.site.com/robots.txt</i>) and can contain either generic rules (specified by the wildcard character *) or specific rules (only for Googlebot, for instance).

Generically, Robots.txt files have got a standardised structure that you can find in <a href="http://tools.seobook.com/robots-txt/" title="Robots.txt structure guide" target="_blank">this guide</a>.

Like with the Sitemaps, Google Search Console has got an online tester for Robots.txt. Here, you can test its syntax and submit it.

The Robots.txt of our website reads like this:
<i>For all crawlers, do not disallow any route, and the site’s sitemap is located at: https://marsbased.com/sitemap.xml</i>. You can find it here: <a href="https://marsbased.com/robots.txt" title="MarsBased robots.txt" target="_blank">https://marsbased.com/robots.txt</a>

To learn more about Robots.txt and everything involved, check <a href="https://support.google.com/webmasters/answer/6062608?hl=en" title="Google's robots.txt files 101" target="_blank">Google’s detailed guide about this file type</a>.

Our sitemaps, generically, will be like this one:

```
   User-agent: *
   Sitemap: https://www.marsbased.com/sitemap.xml
```

These two lines mean that all crawlers are allowed (*) and the address of the sitemap file. We will generally not disallow access to assets unless we see it affects performance. In the past, access to CSS and JS files was blocked, but not anymore, and Google strongly discourages it.

Once you're past all the previous setup concerning Google Analytics and Google Search Console and your sitemap and robots files are correctly configured, let's code!

# HTTPS

Before getting into actual code, you will need to enforce secure connections to your site.

Since 2015, <a href="http://thenextweb.com/google/2015/12/17/unsecured-websites-are-about-to-get-hammered-in-googles-search-ranking/#gref" title="HTTPS sites rank better in Google" target="_blank">HTTPS-enforced websites rank better</a>. Therefore, make sure you include HTTPS in your project.

As we specified briefly in the Google Search Console section, you will need to add the HTTPS variants of your domain.

# Tags, metatags and else

Finally, we can get our hands on the code!

A lot of things have changed in the last few years. Don’t trust what you remember to be true from 2004. Google is constantly experimenting and altering its algorithm, so you need to catch up on the recent happenings.

Since we're writing an SEO 101 here, we will review the basics we implement in each project.

## Metatags

We will implement the following tags in the `<head>`:

    <meta name="author" content="www.marsbased.com">
    <meta name="copyright" content="2016 MarsBased">
    <meta content="MarsBased is a development consultancy from Barcelona for web & mobile apps based on Ruby on Rails and AngularJS. Contact us for a free estimate for your app." name="description" />

The description needs to be adapted to the project’s description. Author and Copyright might stay like this unless the client states otherwise.

The metatag `keywords` is deprecated. So don’t include it.

## Tags

Each page needs a `<title>` tag like this:

    <title>MarsBased | Ruby on Rails development consultancy</title>

The `|` character separates entities. Typically the following structures are used:

* `Brand name | description | page name`
* `Description | page name | brand name`
* `Page name | brand name`
* Etc.

The length of this string should not exceed 55-60 characters, as Google will only display as many.

This is the most important tag on the page, so make sure to introduce keywords and the brand name. Simpler is better.

Some considerations for the title:

* As stated previously, no longer than 60 chars.
* Use keywords, but just one.
* Include your company’s name.
* DO NOT REPLICATE THEM - make sure each page has a unique title.
* For hardcore understanding of this topic, use <a href="https://searchenginewatch.com/sew/how-to/2154469/write-title-tags-search-engine-optimization" title="Title tag on SEO" target="_blank">this article about the title tag written by Search Engine Watch</a>.

## Schema.org

This one is painful to implement the first time, but once you get it, it’s really quick.

Head out to the <a href="http://schema.org/" title="Schema.org official website" target="_blank">Schema.org official website</a> to find out more.

Basically, this adds extra information to the HTML tags and attributes in order to help search engines understand complex data models and their attributes, so they can create rich snippets.

In these pages, the Schema for recipes has been used, highlighting not only the picture but also the ratings, the number of votes, number of reviews, the cooking time and the calories count.

Pages with schema.org provide more meaningful information to the users, but also to the crawlers, and therefore rank better.

Frontend developers might have some concerns about how this can pollute their code. We actually wrote a piece on <a href="http://www.alexrodba.com/2016/03/23/How-To-Include-Extra-Schema-Org-Metadata-Without-Messing-Your-Content.html" title="How to include extra schema.org metadata without messing your content" target="_blank">how to include schema.org metadata without interfering with your current code</a>.

## The content

Some basic rules for content. They’re too many to remember unless you’ve been doing this for years. Use this as a checklist:

* Anchor (`<a>`) elements should always include the `alt` and `title` attributes, as descriptive as possible. Use keywords!
* Avoid using “<i>click here</i>” as labels for anchors. Use descriptive text like “<i>read our favourite article about SEO for multilanguage sites</i>”.
* Anchor elements to other websites, ALWAYS with a `target=_blank` attribute. We don’t want to lose navigation to other websites.
* Images should ALWAYS include a descriptive `alt` attribute. Use keywords!
* No more than one `h1` per page.
* `<h1>` only includes `<h2>` (as many as you need). `<h2>` only includes `<h3>`, and so forth. Headers should be hierarchical.
* Make sure that <strong>every page of the site is linked from another page</strong>. The site needs to be fully navigable just by following links. Otherwise, crawlers will not be able to do it.
* Make sure you use the right keywords for the blog posts and content on the site.

We should also avoid duplicated content. In our projects, most likely we will only get duplicated content because of a poor configuration of the multi-language. If the client steals content from other sites we can't control it. Anyways, read <a href="https://moz.com/learn/seo/duplicate-content" title="Duplicate content" target="_blank">this article on how to deal with duplicated content using the rel=canonical tag, written by Moz</a>.

For the extra points, use <a href="https://developers.google.com/speed/pagespeed/insights/?hl=en&utm_source=wmx&utm_campaign=wmx_otherlinks&url=http://marsbased.com/" title="pagespeed insights by google" target="_blank">Pagespeed Insights (by Google)</a> to help you to create the best experience.

# Bonus track #1: Migrations

This is critical: if we’re migrating a project from a URL structure to a different one, we need to massively redirect all old URLs with 301’s to the new ones. Otherwise, we will lose all traffic. We strongly recommend reading these articles:

* <a href="https://www.quicksprout.com/2014/06/02/how-to-retain-at-least-95-of-your-organic-traffic-after-a-site-redesign/" title="How to retain at least 95% of your traffic after a site redesign by Quicksprout" target="_blank">How to retain at least 95% of your traffic after a site redesign by Quicksprout</a>.
* <a href="http://savvypanda.com/blog/intermediate-level/how-to-change-domain-names-not-lose-seo.html" title="How to change domain names and not lose SEO by SavvyPanda" target="_blank">How to change domain names and not lose SEO by SavvyPanda</a>.

Another important thing is that the old site might have metatags as validators (to validate domain names, licenses and whatnot). Make sure you migrate these as well. 

If we don't migrate these, some services might stop working!

# Bonus track #2: Multi-language sites

Because we've got clients from all over the world, we sometimes work with multi-language sites. Here we need to properly tell the crawlers that two pages have the same content albeit in different languages.

We need to tell the crawlers that two pages are the same, but in different languages. This is configured using some tags, and a couple of tweaks in Google Webmaster Tools. Read more about it in this <a href="https://support.google.com/webmasters/answer/189077?hl=en" title="Multi-language sites and SEO" target="_blank">excellent guide for multi-language sites, written by Google</a>.

<hr/>

If you have read this far, hats off! This is but a very brief and quick introduction to the basics of SEO we introduce in every project we develop. We cannot cover everything and we try to optimise our time as much as possible.