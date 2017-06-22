module Danger
  #
  # The idea of the plugin is to let the machine rules the PR reviewers decision =)
  # * It will assign a random %n developers from the given Array to review the code
  # * It will assign a random %n designers from the given Array to
  #   review the UI if there is an image attached to the PR body
  #
  # @example Assigns reviewers for the PR
  #
  #          pr_reviewers.run
  #
  # @see  conichiGMBH/danger-pr_reviewers
  # @tags github, review, mention
  #
  class DangerPrReviewers < Plugin
    # Request a review from potential reviewers.
    #
    # @param   [Integer] number_of_code_reviewers
    #          Maximum number of developers to request a review from, default is 1.
    # @param   [Integer] number_of_design_reviewers
    #          Maximum number of designers to request a review from, default is 1.
    # @param   [Array<String>] developers
    #          List of developers GitHub's usernames.
    # @param   [Array<String>] designers
    #          List of designers GitHub's usernames.
    # @return  [void]
    #
    def run(developers, designers, number_of_code_reviewers = 1, number_of_design_reviewers = 1)
      unless @dangerfile.github.pr_author.nil?
        developers -= [@dangerfile.github.pr_author]
        designers -= [@dangerfile.github.pr_author]
      end
      reviewers = find_developers(number_of_code_reviewers, developers)
      reviewers += find_designers(number_of_design_reviewers, designers) if need_design_review?
      request_review(reviewers)
      message("Danger has assigned @#{reviewers.join(' @')} to review the PR", sticky: true)
    end

    private

    def find_developers(number_of_code_reviewers, developers)
      developers.sample([number_of_code_reviewers, developers.count].min)
    end

    def find_designers(number_of_design_reviewers, designers)
      designers.sample([number_of_design_reviewers, designers.count].min)
    end

    def need_design_review?
      pr_body = @dangerfile.github.pr_body
      return true if pr_body =~ /<img([\w\W]+?)>/
      return true if pr_body =~ %r{\[.*\]\((https|http):\/\/.*\.(PNG|png|jpeg|jpg)\)}
      false
    end

    def request_review(reviewers)
      github = @dangerfile.env.request_source
      pr_id = @dangerfile.env.ci_source.pull_request_id
      repo = @dangerfile.env.ci_source.repo_slug
      github.client.request_pull_request_review(repo, pr_id, reviewers)
    end
  end
end
