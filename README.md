# danger-pr_reviewers

The plugin deals with the PRs on the GitHub innregards to reviews. Based on the given parameters
it automatically assigns the developer to review the PRs. In [ios team](https://github.com/conichiGMBH/ios-team) we have [rules](https://github.com/conichiGMBH/ios-team/blob/master/docs/pr_protocol.md#creating-the-pr) to ask our designers to review the UI changed in PR, by checkin the attached image or gif. The `pr_reviewers` can also ask for review based on that rule.

## Installation

```
$ gem install danger-pr_reviewers
```

## Usage

```ruby
developers_usernames = ["Superman", "Batman", "Iron-Man"]
number_of_developers_required_for_review = 1
designers_usernames = ["Pablo-Picasso", "Salvador-Dali"]
number_of_designers_required_for_review = 1
pr_reviewers.run(developers_usernames,
                 designers_usernames,
                 number_of_developers_required_for_review,
                 number_of_designers_required_for_review)
```

## Development

1. Clone this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.
