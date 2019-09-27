# The MarsBased Curated Angular Reference Guide

Among all the MarsBased devs, we share useful Angular resources, questions, experiences, tools, guides and tutorials to keep this curated Angular reference post up-to-date. Enjoy it!

Most of the frontend projects we have developed until now have used Angular. As a result, we accumulate (and share) a lot of Angular knowledge inside the company. Most recently, we've blogged about <a href="https://marsbased.com/blog/2019/06/17/angular-view-encapsulation/" title="Comparing the Three Angular View Encapsulation Methods" target="_blank">Comparing the Three Angular View Encapsulation Methods</a>, <a href="https://marsbased.com/blog/2019/05/13/change-detection-strategy-angular/" title="Changing Detection Strategy in Angular" target="_blank">Changing Detection Strategy in Angular</a>, and we've even sent out <a href="https://mailchi.mp/1eb143713cff/welcome-to-the-marsbased-newsletter-2415953" title="MarsBased newsletter" target="_blank">a dedicated MarsBased newsletter about Angular</a>.

## Getting started

First off, let's kick this off with some very basic guides and documentation to help you set you up with Angular.

The most important resource, and best so far, it is the official documentation: <a href="https://angular.io/docs" title="Official Angular Documentation" target="_blank">https://angular.io/docs</a>.

In the official Angular documentation you can find:

* __Fundamentals:__ <a href="https://angular.io/guide/architecture" title="Official Angular Documentation" target="_blank">https://angular.io/guide/architecture</a>.
* __Tutorial:__ <a href="https://angular.io/tutorial" title="Official Angular Documentation" target="_blank">https://angular.io/tutorial</a>.
* __Style Guide:__ <a href="https://angular.io/guide/styleguide" title="Official Angular Documentation" target="_blank">https://angular.io/guide/styleguide</a>.
* __Angular CLI:__ <a href="https://cli.angular.io/" title="Official Angular Documentation" target="_blank">https://cli.angular.io/</a>.

Additionally, we recommend a course that doesn't require previous experience, and it includes TypeScript lessons: <a href="https://www.udemy.com/the-complete-guide-to-angular-2/" title="The Complete Guide to Angular 2" target="_blank">The Complete Guide to Angular 2</a>. You probably will know the author, Maximilian Schwarzmüller, as he has more frontend courses.

We've got to say, though, that you will find some of these lessons to be irrelevant if you are an experienced developer, but the course covers the important concepts and adds some extra interesting lessons.

__Ultimate Courses__ has a good collection of beginner/advanced courses. They are not free but the range of lessons and contents you can access is very broad: <a href="https://ultimatecourses.com/courses/angular" title="Ultimate Courses Angular" target="_blank">https://ultimatecourses.com/courses/angular</a>.

In this section, I'd also like to recommend a book that is a great resource to start learning: the Rangle.io Angular book. <a href="https://angular-2-training-book.rangle.io/" title="Rangle.io Angular book" target="_blank">https://angular-2-training-book.rangle.io/</a>.

And how about the tools? __Visual Studio Code__ is our favorite IDE. Its integration with Angular and TypeScript is awesome and the list of available plugins is nearly endless. Moreover, it has a great community and the development experience is gratifying. Go get it in the <a href="https://code.visualstudio.com/" title="Visual Studio Code Official Website" target="_blank">Visual Studio Code Official Website</a>.

## Important libraries

__TypeScript__ will become your companion in this journey, so make sure you master it. In the resources listed in the previous section, you can have a good introduction to TypeScript but check the <a href="https://www.typescriptlang.org/docs/home.html" title="TypeScript official documentation" target="_blank">TypeScript official documentation</a>. TypeScript shouldn't be underestimated, for it is an impressive language that will ease your way into Angular development.

Related to TypeScript, there is the __TSLint__ tool, which __is a must__. TSLint helps you to write consistent and uniform code across the entire application.

We have created our own configuration based on our past experience, which we use it for every Angular project, the <a href="https://www.npmjs.com/package/@marsbased/marstyle-angular" title="Marstyle Angular Library for TSLint" target="_blank">@marsbased/marstyle-angular library</a>.

One of the most powerful and essential libraries you need to know is the __RxJS library__. RxJS enables you to use reactive programming: an asynchronous paradigm to handle events and data flow in Angular applications.

Some resources about reactive programming:

* __Official documentation:__ <a href="https://rxjs-dev.firebaseapp.com/" title="RxJS documentation" target="_blank">https://rxjs-dev.firebaseapp.com/</a>
* __Angular RxJS tutorial:__ <a href="https://angular.io/guide/rx-library" title="Angular RxJS tutorial" target="_blank">https://angular.io/guide/rx-library</a>

RxJS is a powerful tool, but it comes with a set of drawbacks, too. Don't forget to take a look to our blog post about <a title="Dealing with Memory Leaks in ReactiveX" href="https://marsbased.com/blog/2018/06/18/dealing-with-memory-leaks-reactivex/" target="_blank">Dealing with Memory Leaks in ReactiveX</a> to dig deeper into more advanced notions.

__Angular Material__ is another helpful library. It has a big catalog of components you can reuse in your projects, so you can create new Angular styled projects in little to no time. Check it out: <a href="https://material.angular.io/" title="Angular Material" target="_blank">https://material.angular.io/</a>.

## State Management

The Redux pattern had an impact in Angular too and, thus, some libraries have been created to implement it. Depending on the size and needs of the project you can choose between the following options:

* __NgRx__: One of the most popular options. Check the <a href="https://ngrx.io/" title="NgRx official documentation" target="_blank">official NgRx documentation</a> and <a href="https://blog.angular-university.io/angular-2-redux-ngrx-rxjs/" title="Angular 2 Redux NgRx RxJS" target="_blank">this blog post talking about when you can use it</a>.
* __Akita__: This library is perfect for small projects. You can read the <a href="https://github.com/datorama/akita" title="Akita official documentation" target="_blank">Akita official documentation</a> and another guide of <a href="https://blog.angularindepth.com/state-management-in-angular-using-akita-82f117d282dd" title="How to use Akita" target="_blank">how to use Akita in Angular projects</a> for further details.
* __NGXS__: Easier to understand than NgRx since it is more Angular-ish and has a lot less boilerplate. Read the <a href="https://ngxs.gitbook.io/ngxs/" title="Official NGXS documentation" target="_blank">Official NGXS documentation</a> and this guide to help you get started: <a href="https://alligator.io/angular/ngxs/" title="How to get started with NGXS" target="_blank">https://alligator.io/angular/ngxs/</a>.

## Testing

Frontend testing is not an easy task, but there are several useful resources and libraries this process less painful (and, as some say, more enjoyable!). These are the tools we recommend:

* __Jest__: For unit tests mainly. Similar to jasmine, but with a big set of matchers and tools. Try the snapshot feature and you will stop navigating in object properties to write your asserts. Check the <a href="https://jestjs.io/" title="Jest official documentation" target="_blank">Jest official documentation</a>.
* __Cypress__: e2e tests. Fun and easy to use. This library mimics user interaction with the application. Check the <a href="https://www.cypress.io/" title="Cypress official documentation" target="_blank">Cypress official documentation</a>.

## Deeper guides and more advanced articles

Once you know the basics, you'll want to dig deeper into the advanced Angular patterns and resources. For this, there are a couple of pages we highly recommend:

* __Alligator__: They have high-quality Angular guides and articles, not only for beginners but also for experienced developers. Furthermore, they post about Vue, React or JavaScript in general. Check the <a href="https://alligator.io/angular/" title="Alligator website" target="_blank">Alligator website</a>.
* __Angular in Depth__: Excellent Angular articles covering architecture, patterns, and libraries. Find all of this in the <a href="https://blog.angularindepth.com/" title="Angular in Depth blog" target="_blank">Angular in Depth blog</a>.

## Bonus!

Check out some other great Angular articles we have cherrypicked for you. They all review Angular key concepts and we've learnt a lot from them:

* __Reddit Angular 2+:__ You will find interesting threads and some advanced questions in the <a href="https://www.reddit.com/r/Angular2/" title="Reddit Angular 2" target="_blank">Reddit community about Angular 2+</a>.
* __Angular University:__ Although it's not updated anymore, they have great articles and tutorials still useful for most people. Browse them at <a href="https://blog.angular-university.io" title="Angular University" target="_blank">Angular University</a>.
* __Angular cheatsheet__: One of my favorites when starting out with Angular development. The ultimate <a href="https://angular.io/guide/cheatsheet" title="Angular cheatsheet" target="_blank">Angular cheatsheet</a>.
* __Egghead__: Top developers give insightful and interesting talks on this platform. Find out more about <a href="https://egghead.io/courses/for/angular" title="Egghead" target="_blank">Egghead</a>.
* __Adventures in Angular:__ If you are into podcasts, this is one of the best. Join me in following the <a href="https://devchat.tv/adv-in-angular/" title="Adventures in Angular podcast" target="_blank">Adventures in Angular podcast</a>!
* __Angular Awesome:__ If you really really REALLY want to know all the things Angular, check out this incredible repository with dozens of resources: <a href="https://github.com/PatrickJS/awesome-angular" title="Angular Awesome" target="_blank">Angular Awesome</a>.

<hr>

Are you missing any resource or interesting article on this list? Feel free to suggest additional useful resources by creating a PR to let us know!
