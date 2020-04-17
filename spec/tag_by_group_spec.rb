# frozen_string_literal: true

require 'rails_helper'

describe "tag_by_group" do
  before do
    SiteSetting.tagging_enabled = 'true'
    SiteSetting.tag_by_group_enabled = true
    SiteSetting.tag_by_group_tags_for_groups = "customers,high-priority"
  end

  it 'tags topics created by group member' do
    customer = Fabricate(:user)
    group = Group.create!(name: 'customers')
    group.add(customer)
    group.save
    topic = Fabricate(:topic, user: customer)

    DiscourseEvent.trigger(:topic_created, topic)

    expect(topic.tags.last.name).to eq('high-priority')
  end
end
