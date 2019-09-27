

Since we started MarsBased, we've completed a good share of projects. From all of them we've learnt something useful. But all this knowledge should be stored somewhere for further use, for instance, to train new developers.

Pretty much like we did with the release of the MarsBased blogging guide (<a href="http://marsbased.com/blog/2015/05/13/The-MarsBased-Blogging-Guide" title="How to Create a Damn Good Blog Post" target="_blank">part 1</a>, <a href="http://marsbased.com/blog/2015/08/16/How-to-Create-a-Blogging-Strategy-for-your-Company" title="How to Create a Blogging Strategy for Your Company" target="_blank">part 2</a>), we want to share what we have learnt about HTML5 & CSS3 with you all.

Things should not only work well. They can also look good.

Frontend developers, this one is for you.

# Workflows

Before we delve into the technologies we use, we will introduce our working methodologies here:

## Task management

<a href="www.trello.com" title="Trello" target="_blank">Trello</a> is our tool of choice for managing tasks and weekly sprints.

We have one board for each project. Inside the project's board, you'll find columns for the present and coming weeks, along with <i>Done, Review Pending, Bugs, Features,</i> and <i>Backlog</i>. In projects that have been already rolled out, you will see some columns for the deploys management, too.

The Project Manager is in charge of assigning the layout & design tasks. You will see the cards assigned to you in the present week column. Once you have finished a task, you must add a new comment indicating the relevant pull request link, and move the card to the <i>Review</i> Pending column.

The Project Manager will review the implementations and move the card to <i>Done</i>, send it back to you (if there is something to fix) or forward it to the Development Team.

The weekly sprints are defined on Mondays, in an online meeting between you and the Project Manager. However, don't hesitate to get in touch with the Project Manager at any time, if you need to discuss anything or have any question.

## Commits & Branches

We work with both <a href="github.com" title="Github" target="_blank">Github</a> and <a href="bitbucket.org" title="Bitbucket" target="_blank">Bitbucket</a> and we always have separate repositories for the layout implementation and the development, so you don't have to worry about breaking stuff or learning Ruby on Rails. In other words, you will have to deal with HTML, CSS, and JS, only.

Furthermore, we never work on the <i>master</i> branch, as it only contains reviewed and finished stuff. Usually, we create a new branch for each task. However, we sometimes group small and related tasks to use only one branch for them. Apply common sense and branch wisely!

The Project Manager will merge those branches into <i>master</i> after making the relevant reviews.

Finally, when we make commits, we always include the type of change we have made between brackets.

For example, if you've changed only the CSS code, you indicate:

<code>[CSS] Replaced the body background color.</code>

If you have changed the HTML and you have replaced some images, you will write:

<code>[HTML+IMG] Replaced the default avatar.</code>

You might want to include other indications like <i>JS, README, CONFIG,</i> etc. This way, our developers will be able to identify very quickly what they have to change in the development to replicate our work.

## Testing

Quality is one of the founding values of MarsBased. A while back ago, we defined quality as "<i>meeting and exceeding clients expectations while maintaining our own methodologies</i>". For that reason, exhaustive and successful testing is critical in our day to day.

As a front end developer, you’re in charge of testing how the applications look in all the required browsers and devices.

Our testing workflow is plain and simple:

* In new projects where we start the development from scratch, we leave the testing tasks for the end and we do them all at once.
* In projects under maintenance (live products), we test each new feature or bug fix before sending the pull request to the development team.

Keep this in mind all the time: an excellent developer is not just someone who creates good code, but is also a good tester.

# Tech Stack and Guidelines

## Middleman

<a href="middlemanapp.com" title="Middleman" target="_blank">Middleman</a> is a static websites generator built with Ruby on Rails. It integrates all the state-of-the-art frameworks and tools for frontend development (like SASS, Modernizr, Compass, Autoprefixer...) and allows you to use templating languages such as ERB or Liquid.

All our new projects are developed using Middleman, but before that, we used <a href="jekyllrb.com" title="Jekyll" target="_blank">Jekyll</a>. Jekyll is very similar to Middleman, with only a few differences between them. While we used Liquid as the templating language in Jekyll, now we switched to ERB in Middleman.

In the project's README file, you will find instructions about how to install the required packages and run any of those tools.

### MIDDLEMAN TOOLS

* Middleman lets you organize your code in layouts and partials. Do it wisely, we don't want to have to deal with tons of files. Use partials only for stuff that will appear in several pages, or to split the code of very long pages, but always remember that <i>simpler is better</i>.
* We have developed our own Middleman template called MarsMan. We use it as a model to create new projects. It contains all the folders, SASS mixins, frameworks and libraries that we use in our projects. Marsman is an open source project, so you can use it for your personal stuff or even send it to other people. You can download the code from <a href="https://github.com/MarsBased/marsman-template" title="MarsBased Github profile" target="_blank">our Github profile</a>.
* We use the Middleman helper <i>page_classes</i> to define <i>page-specific</i> classes in the body tag of the HTML. Use them carefully, we don't want to create too many page dependencies in our CSS code.
* Middleman has a very useful set of helpers that let you add random Lorem Ipsum content and image placeholders.
* Middleman allows you to add Markdown content to a website by simply including a markdown file as a partial inside any other HTML file. We use Markdown files for text-only pages like Terms & Conditions, Privacy Policy or blog posts.

You can find more information about Middleman and Jekyll in their official websites.

Also, if you never had the chance to use ERB, you can find some examples in <a href="http://benfrain.com/understanding-middleman-the-static-site-generator-for-faster-prototyping/" title="Middleman" target="_blank">this blog post</a>.

## Bootstrap

Most of our works are based on <a href="http://getbootstrap.com/" title="Bootstrap" target="_blank">Bootstrap</a>. It's a very well-known markup framework and it offers good compatibility with browsers and other components. Also, our developers are familiar with it and can reuse a lot of code.

We tend to use always the last stable version of Bootstrap, in their SASS distribution. Since we also use SASS as our CSS framework of choice, you will be able to replace the Bootstrap variables and adapt them to each project. Do it whenever possible, instead of overwriting the Bootstrap properties. You can find the complete list of variables in the <a href="https://github.com/twbs/bootstrap-sass/blob/master/assets/stylesheets/bootstrap/_variables.scss" title="Bootstrap SASS Github page" target="_blank">Bootstrap SASS Github page</a>.

Finally, Bootstrap has a very powerful grid system. It can be used by simply including classes in the HTML markup, such as <i>.row</i> or <i>.col-xs-6</i>. However, instead of using those classes to define rows and columns, we prefer to use the Bootstrap mixins. They also allow you to define rows and columns, but you can do it directly in the SASS files, without dirtying the HTML code. Following this approach, we can completely separate the markup of a website from its styles and we make the application easier to maintain.

In other words, instead of doing:

```
<div class="container">
  <div class="results row">
    <div class="item col-xs-12 col-sm-6 col-md-4">
      The Martian
    </div>
  </div>
 </div>
```

We prefer to do:

```
<div class="container">
  <div class="results">
    <div class="item">
      The Martian
    </div>
  </div>
 </div>
```

And:
```
.results
  +make-row()
.item
  +make-xs-column(12)
  +make-sm-column(6)
  +make-md-column(4)
```

You can see the <a href="https://github.com/twbs/bootstrap-sass/blob/master/assets/stylesheets/bootstrap/mixins/_grid.scss" title="Mixins used in the grid system" target="_blank">mixins used in the grid system</a> also in Github.

## SASS

SASS is a CSS preprocessor that lets you use variables, functions, operations, and other useful stuff inside your CSS stylesheets. You can learn how to use SASS in their <a href="http://sass-lang.com/" title="SASS official website" target="_blank">official website</a>. We're sure you'll find it very easy!

### PARTIALS
We organize our SASS code in partials that we later import in a single file called <i>application.sass</i>.

These partials are organized in folders. Take a look at this example:

```
/stylesheets

  /utils
    _mixins.sass
    _variables.sass
    _helpers.sass
    _keyframes.sass

  /modules
    _navbar.sass
    _footer.sass
    _items.sass
    _filters.sass

  /layouts
    _home.sass
    _results.sass

  application.sass

```


The <i>/utils</i> folder is where we store our helpers, mixins and keyframes - coding tools that we use in our HTML and SASS files. We also have a file called <i>_variables.sass</i> that contains generic variables like color or typography definitions. However, page- or module-specific variables are not stored here but inside the corresponding layout or module file (you can find an example a couple of paragraphs from here).

The <i>/modules</i> folder contains the styles of the different components that compose each page. And finally, we use the <i>/layouts</i> folder to include styles we need to apply to specific pages.

If the difference between layouts and modules is still not clear for you, have a look at the following example.

Let's say that we have to develop a marketplace with a results page, where each result is an item. Some of these items will also appear in the Home page.

We would create a <i>_items.sass</i> file inside <i>/modules</i> and we would put there all the styles that apply to the items.

```
// modules/_item.sass

.item

  $item-primary-color: #000000 // Variable specific to this module!

  padding: 20px
  background-color: #f4f4f4

  .title
    color: $item-primary-color
```

Now consider that these items have to look differently in the Homepage than in the Results view. In that case, we would create a <i>_home.sass</i> file inside <i>/layouts</i> with the following styles:

```
// modules/_home.sass

.home
  .item
    background-color: inherit
```

### NAMING CONVENTIONS

In order to name our elements and classes, we follow the modular approach explained in <a href="http://thesassway.com/advanced/modular-css-naming-conventions" title="Modular CSS naming conventions" target="_blank">this article</a> from <a href="http://thesassway.com/" title="The SASS Way" target="_blank">The SASS Way</a>. However, we don't apply the <i>parent-child</i> rules, as we prefer to use nesting for such cases. In any case, if you ever have to define parent-child relations, use a dash (-) as a separator instead of an underscore (_) or any other symbol.

Finally, in order to differentiate keyframes (animations) from classes or IDs, we name them without dashes or underscores:

```
// Keyframes

@keyframes fadeIn
  0%
    opacity: 0
  100%
    opacity: 1

@keyframes fadeOut
  0%
    opacity: 1
  100%
    opacity: 0
```

### OTHER GUIDELINES

* You can create your own mixins, but do it only when they will save you a lot of time, without adding too much complexity to the project. We don't want to increase the application complexity because other less experienced coders might have to work on it at some point.
* Nesting is one of the most powerful tools of SASS. However, it can be counterproductive if not used wisely. We follow the <a href="http://thesassway.com/beginner/the-inception-rule" title="The Inception Rule" target="_blank">Inception Rule</a> defined in The SASS Way. It says that you can't go more than four levels deep. It also explains how to organize the different selectors and properties in site-wide rules, page specific rules and objects.
* In projects where we don't have to support IE8 or lower, we use REM units to define font sizes, margins, heights, widths, etc. REM units work in a similar way than EMs, but they are proportional to the HTML tag <i>font-size</i>. Bootstrap defines the HTML <i>font-size</i> to 10px, so using REM units is very easy: 1rem will always be equal to 10px, 1.4rem will be equal to 14px, 0.8rem will be equal to 8px, and so on.

## Autoprefixer, Modernizr, and Compass

<a href="https://github.com/middleman/middleman-autoprefixer" title="Autoprefixer" target="_blank">Autoprefixer</a> is a plugin that parses the CSS files and adds browser specific prefixes to the properties that require them. This means that you don't have to worry about adding prefixes such as -webkit-, -moz- or -ms- because Autoprefixer does it for you.

<a href="http://modernizr.com/" title="Modernizr" target="_blank">Modernizr</a> is a JavaScript library that detects if the user's browser supports HTML5 and CSS3 features or not. You can use it to build fallbacks for modern features that old browsers might not support.

<a href="http://compass-style.org/" title="Compass" target="_blank">Compass</a> is another CSS framework included in our Middleman projects. We prefer to use Autoprefixer to add browser specific prefixes, but you might want to use Compass for other things, like its vast library of reliable mixins.

## Images and icons

### VECTORIAL IMAGES

For logos, icons and small images we prefer to use SVG files instead of PNGs or JPGs because SVGs are made from vectors and can be resized without losing quality.

To include SVG files in the HTML code, drop the SVG files in the <i>shapes</i> directory. All SVG files are formatted in XML. Make sure that they don't have more data than the necessary (some apps like Adobe Illustrator include irrelevant information inside the SVG files that can produce errors).

Afterwards, you will have to execute a job that will take all the SVG files from the <i>shapes</i> directory and produce a file called <i>shapes.html</i>:

```
grunt svg
```

This file should be included in all the app's pages as a partial:


 ```
 <body class="<%= page_classes %>">
  <%= partial "partials/shapes" %>
  <%= yield %>
  <%= javascript_include_tag  :application %>
 </body>
 ```


Now you can include any SVG image in your HTML by simply calling it. Use this markup to do it so:

```
<svg class="shape shape-filename">
  <use xlink:href="#shape-filename"></use>
</svg>
```

### BOOTSTRAP GLYPHICONS AND FONT AWESOME

If the design doesn't come with its own icons, we like to use the ones provided by Bootstrap and Font Awesome. If you don't find any suitable icon, try looking in websites like <a href="iconfinder.com" title="Iconfinder.com" target="_blank">iconfinder.com</a>.

### IMAGE HELPERS

In some cases, we will have to deal with normal images like PNGs or JPGs. In that case, we use the image-url helper in the CSS files to point to files stored in the images folder:

```
.navbar
  background: image-url('navbar-background.png')
```

In the HTML markup, however, we use another helper called <i>image_tag</i>:

```
<%= image_tag 'padrino.png', width: '35', class: 'logo pull-right' %>
```

You can find more examples of the <i>image\_tag</i> helper in the <a href="http://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html#method-i-image_tag" title="Ruby on Rails API documentation" target="_blank">Ruby on Rails API documentation</a>.

## JS libraries

Not all the JS libraries work well with Rails and AngularJS. For that reason, and also because we like to standardize the code of our projects, we have created a list of preferred libraries. If you ever have to use another library, consult our Development Team first.

* <b>Modals:</b> ng-dialog (only in AngularJS projects) and Bootstrap.
* <b>Dropdown menus:</b> Bootstrap.
* <b>Selects:</b> Select2.
* <b>Tabs:</b> Bootstrap.
* <b>Carousels:</b> Slick.
* <b>Checkbox and radio buttons:</b> Pure CSS (label after the input technique).
* <b>Charts:</b> C3 & D3.
* <b>Autocomplete:</b> Select2.
* <b>Range sliders:</b> bootstrap-slider.
* <b>Scroll:</b> Just the browser scrollbar (avoid using JS scrollbars like Perfect Scrollbar if possible).
* <b>Affix & Scrollspy:</b> Bootstrap.
* <b>Tooltips & popovers:</b> Bootstrap.
* <b>Alerts:</b> Bootstrap + simple fade in with JS.
* <b>Text editors:</b> TinyMCE.
* <b>Date management:</b> MomentJS.
* <b>Datepickers:</b> Pickadate.
* <b>Animations:</b> Pure CSS. Velocity if more complex animations are needed.
* <b>Progress Bars:</b> Pure CSS.
* <b>Maps:</b> Leaflet or Google Maps.
* <b>Parallax:</b> Pure CSS.
* <b>Image galleries:</b> Slick.js inside a modal.
* <b>Chat mentions:</b> AT.js.

## Code spacing and formatting guidelines

### 80 CHARACTERS PER LINE

It's not always possible, but in order to improve code legibility we try to make lines no longer than 80 characters (this applies to HTML, JS, and SASS too).

If you have to split an HTML tag, do it between attributes and indent the second line:

```
<a class="item-link" href="http://www.marsbased.com"
  target="_blank">
  MarsBased Website
</a>
```

Advanced text editors like Sublime Text allow you to add a ruler on your screen that mark where the 80 characters per line are reached.

### HTML FILES

We don’t include any extra line-breaks between <i>divs</i> and other elements. Also, we avoid using HTML comments unless they are completely necessary to explain how something is supposed to work.

For example, instead of doing:

```
<div class="results">

  <div class="item">
    <h2>MarsBased website</h2>
  </div><!-- .item -->

</div><!-- .results -->
```

We prefer to do:

```
<div class="results">
  <div class="item">
    <h2>MarsBased website</h2>
  </div>
</div>
```

<b>Bonus:</b> there is a Sublime Text plugin called <a href="https://github.com/SublimeText/TrailingSpaces" title="TrailingSpaces" target="_blank">TrailingSpaces</a> that detects unnecessary blank spaces in your code and deletes them all at once with a keyboard shortcut!

### SASS FILES

If a CSS selector doesn’t have any property inside it, we leave no space between the selector and the selector that comes next:

```
.results
  .item
    border: 1px solid purple
```

On the other hand, if a selector has some properties, we add an extra line break between the last property and the next selector:

```
.results
padding: 10px 20px

.item
border: 1px solid purple
```

### SEO

We follow the SEO best practices of naming all the elements with HTML5 semantic tags, when possible, like <i>header, aside, section, nav, footer, article,</i> etc.

Inside each of these tags, we try to respect a hierarchic structure of headings. It sounds obvious, but <i>h1</i> elements must contain <i>h2</i> and not the other way around.

Finally, we always add the <i>title</i> attribute to all the links and <i>title</i> and <i>alt</i> to all the images.

Have a look at <a href="https://developer.mozilla.org/en/docs/Sections_and_Outlines_of_an_HTML5_document" title="HTML5 elements" target="_blank">this website</a> for a complete guide of HTML5 elements.

### LINKS BETWEEN PAGES

Our layouts are used by our programmers to understand how they have to develop an application. However, our clients use them too to review the status of a project and to show the user interface to other people like investors or partners.

For that reason, we create navigational layouts linking all the pages and our projects can be used as a normal application (although the content is completely static). For example, if someone clicks the “Sign up” link of the navigation bar, we take him to the Sign Up page, where he will be able to check how it looks like.

<hr>
