# frozen_string_literal: true

# name: discourse-tag-by-group
# version 0.1
# authors: scossar
# url: https://github.com/discourse/discourse-tag-by-group

enabled_site_setting :tag_by_group_enabled

after_initialize do
  on(:topic_created) do |topic|
    if topic.archetype == 'regular' && topic.user_id > 0
      u = topic.user
      tag_group_relations = SiteSetting.tag_by_group_tags_for_groups.split('|')
      user_group_names = u.groups.pluck(:name)
      tag_group_relations.each do |r|
        relation = r.split(',')
        if user_group_names.include? relation[0]
          tag_name = relation[1]&.strip
          tag = Tag.find_by_name(tag_name) || Tag.create(name: tag_name)
          if tag && tag.name
            guardian = Guardian.new(Discourse.system_user)
            DiscourseTagging.tag_topic_by_names(topic, guardian, [tag.name], append: true)
          end
        end
      end
    end
  end
end
