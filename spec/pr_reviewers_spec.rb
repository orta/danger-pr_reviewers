require File.expand_path('../spec_helper', __FILE__)

module Danger
  describe Danger::DangerPrReviewers do
    it 'should be a plugin' do
      expect(Danger::DangerPrReviewers.new(nil)).to be_a Danger::Plugin
    end
  end

  context 'with dangerfile' do
    let(:pr_id) { testing_env['TRAVIS_PULL_REQUEST'] }
    let(:repo_slug) { testing_env['TRAVIS_REPO_SLUG'] }
    let(:dangerfile) { testing_dangerfile }
    let(:developers) { ['Antondomashnev', 'Mourad-Aly', 'David-Henner', 'Superman'] }
    let(:designers) { ['denis-sharypin', 'johnny'] }
    let(:pr_reviewers) { dangerfile.pr_reviewers }
    let(:client) { double(Octokit::Client) }
    let(:github) { dangerfile.github }

    context 'in a PR' do
      before do
        allow(client).to receive(:request_pull_request_review).with(anything, anything, anything)
        allow(dangerfile.env.request_source).to receive(:client).and_return(client)
      end

      context 'with the pr author as a deloper' do
        let(:pr_author) { 'Antondomashnev' }

        before do
          allow(github).to receive(:pr_author).and_return(pr_author)
          allow(github).to receive(:pr_body).and_return('Hey! Here is a snapshot of ![simulator screen shot 23 jun 2017 14 19 41](https://user-images.githubusercontent.com/6436181/27482218-d972c1c2-5820-11e7-9806-9006500952de.png)')
        end

        it 'excludes author from potential reviewer' do
          expect(client).to_not receive(:request_pull_request_review).with(repo_slug, pr_id, array_including(pr_author))
          pr_reviewers.run(developers, designers, 4, 2)
        end
      end

      context 'with the pr author as a designer' do
        let(:pr_author) { 'johnny' }

        before do
          allow(github).to receive(:pr_author).and_return(pr_author)
          allow(github).to receive(:pr_body).and_return('Hey! Here is a snapshot of ![simulator screen shot 23 jun 2017 14 19 41](https://user-images.githubusercontent.com/6436181/27482218-d972c1c2-5820-11e7-9806-9006500952de.png)')
        end

        it 'excludes author from potential reviewer' do
          expect(client).to_not receive(:request_pull_request_review).with(repo_slug, pr_id, array_including(pr_author))
          pr_reviewers.run(developers, designers, 4, 2)
        end
      end

      context 'with image' do
        before do
          allow(github).to receive(:pr_author).and_return('Foo')
        end

        context 'inserted as markdown link' do
          before do
            allow(github).to receive(:pr_body).and_return('Hey! Here is a snapshot of ![simulator screen shot 23 jun 2017 14 19 41](https://user-images.githubusercontent.com/6436181/27482218-d972c1c2-5820-11e7-9806-9006500952de.png)')
          end

          it 'asks designer for review' do
            expect(client).to receive(:request_pull_request_review).with(repo_slug, pr_id, array_including_sample_of(designers, 2))
            pr_reviewers.run(developers, designers, 3, 2)
          end

          it 'asks developer for review' do
            expect(client).to receive(:request_pull_request_review).with(repo_slug, pr_id, array_including_sample_of(developers, 3))
            pr_reviewers.run(developers, designers, 3, 2)
          end
        end

        context 'inserted as html tag' do
          before do
            allow(github).to receive(:pr_body).and_return('Please check only what inside the red rectangle 😄 <img src="https://monosnap.com/file/DF8OnfmdHRbJ3UH4e6phCVf8blJln4.png" width=640>')
          end

          it 'asks designer for review' do
            expect(client).to receive(:request_pull_request_review).with(repo_slug, pr_id, array_including_sample_of(designers, 2))
            pr_reviewers.run(developers, designers, 3, 2)
          end

          it 'asks developer for review' do
            expect(client).to receive(:request_pull_request_review).with(repo_slug, pr_id, array_including_sample_of(developers, 3))
            pr_reviewers.run(developers, designers, 3, 2)
          end
        end
      end

      context 'without image' do
        before do
          allow(github).to receive(:pr_author).and_return('Foo')
          allow(github).to receive(:pr_body).and_return('This is my amazing PR without images')
        end

        it 'doesnt ask designer for review' do
          expect(client).to_not receive(:request_pull_request_review).with(repo_slug, pr_id, array_including_sample_of(designers, 2))
          pr_reviewers.run(developers, designers, 3, 2)
        end

        it 'asks developer for review' do
          expect(client).to receive(:request_pull_request_review).with(repo_slug, pr_id, array_including_sample_of(developers, 3))
          pr_reviewers.run(developers, designers, 3, 2)
        end
      end
    end
  end
end
