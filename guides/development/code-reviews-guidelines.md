# Code reviews guidelines

This guide describes some best practices we apply when doing code reviews.

## How to perform a code review

- Review all the code, line by line, and apply the [checklist](#checklist) to all the reviewed code.
- Test all the code: Check both that there are no exceptions and that the correct result is produced.
- Check it correctly solves the issue it addresses. No more and no less.
- Check the produced architecture:
  - It is simple enough, not over-engineered.
  - It is easy to understand.
  - It is easy to extend.
  - It is not trying to predict the future. It just fits the issue it is addressing.
- Check if it has enough automatic tests.

It's useful to take an _algorithmic_ approach when reviewing the code: take one line, apply the checklist, move the next, and repeat.

## Testing the code

Testing the code while doing a review is not something that all companies do, mainly because it can be time consuming. At MarsBased we strongly think it is important to test the code when doing a review. However, take into account that depending on how critical / complex the code is and how difficult it is to test, testing should be less or more exhaustive.

It is a matter of analyzing the cost / benefit ratio and applying common sense to it (is it worth spending a lot of time testing it? it depends on how critical the code is).

## Checklist

This is the main things you should be looking out for in the reviewed code:

- Code additions: Is the new code used?
- Code deletions:
  - Have all uses of the code been removed?
  - Can more now-unused code be removed?
- Typos: Are there any typos in methods / classes / variables names, comments, literals and documentation?
- Good practices: Is the code DRY, with short methods and small classes?
- Code style: Does the code follow the MarsBased conventions and it's idiomatic according to the programming language?
- I18n: Are all strings I18n-ized? (when doing a review for back-end code).
- Background jobs: Are background jobs idempotent? (when doing a review for back-end code).
- Naming: Do classes, methods and variable names use proper naming?
- Database migrations: Do database migrations apply correct constraints that follow model validations? (when doing a review for back-end code).
  - Are changes to schema.rb correct and only related to this PR? (when doing a review for Rails code).

You might have other things that you usually check for. The key idea is that it's useful to have a written list with all those points and apply it consistently without having to think about it every time.

## Comments in code reviews

When writing comments:

- Use "we", not "you". The software engineer is not alone, you are a team.
- Provide objective reasons that support the change. "Because I don't like it" is not a reason.
- Provide an alternative or a sketch of how you would do it instead.
- Don't write only negative comments, write also positive comments:
  - Positive comments increase motivation.
  - Positive comments encourage the software engineer to keep doing the right thing.

Example of a not constructive comment:

> you made this too complex, simplify

Example of a constructive comment:

> This can be simplified, we don't need to extract the numeric values for the status:
>
> - For assignment status we can directly do `where(status: %[preselected selected])`.
> - For appointment status we need to use `merge` otherwise will not work. Instead of `.where(customer_jobs_appointments: { status: appointment_statuses_keys })` we can do `.merge(CustomerJobs::Appointment.where(status: %[warning ready]))`.
>
> Also with these changes we don't need the rubocop disable flag.
