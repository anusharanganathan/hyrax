RSpec.describe ResourceStat, type: :model do
  let(:args) do
    { date: 1.day.ago, pageviews: 25 }
  end

  subject { described_class.new(args) }

  it 'requires a date' do
    expect { described_class.create! }.to raise_error ActiveRecord::RecordInvalid
    expect { subject.save! }.not_to raise_error
  end

  describe ".resource_daily_stats" do
    let(:date) { DateTime.new(2018, 3, 2).in_time_zone }
    let(:non_matching_date) { DateTime.new(2017, 2, 2).in_time_zone }
    let(:user_id) { 123 }
    let(:resource_id) { "199" }

    it 'finds daily statistics for a given resource' do
      ResourceStat.create(date: date, pageviews: 123, resource_id: resource_id, user_id: 123)
      ResourceStat.create(date: non_matching_date, pageviews: 456, resource_id: resource_id, user_id: 123)

      expect(ResourceStat.resource_daily_stats(date, resource_id, user_id).map(&:pageviews)).to eq([123])
    end
  end

  describe ".site_daily_stats" do
    let(:date) { DateTime.new(2018, 3, 2).in_time_zone }
    let(:user_id) { 123 }
    let(:resource_id) { "199" }

    it 'finds site-wide statistics and ignores resource statistics' do
      ResourceStat.create(date: date, unique_visitors: 123)
      ResourceStat.create(date: date, unique_visitors: 456, resource_id: resource_id, user_id: 123)

      expect(ResourceStat.site_daily_stats(date).map(&:unique_visitors)).to eq([123])
    end
  end

  describe ".resource_range_stats" do
    let(:start_date) { DateTime.new(2018, 2, 2).in_time_zone }
    let(:end_date) { DateTime.new(2018, 3, 2).in_time_zone }
    let(:user_id) { 123 }
    let(:resource_id) { "199" }

    it 'finds statistics for a resource in a given time range' do
      ResourceStat.create(date: DateTime.new(2018, 2, 4).in_time_zone, unique_visitors: 123, resource_id: resource_id, user_id: 123)
      ResourceStat.create(date: DateTime.new(2018, 2, 17).in_time_zone, unique_visitors: 234, resource_id: resource_id, user_id: 123)
      ResourceStat.create(date: DateTime.new(2018, 3, 9).in_time_zone, unique_visitors: 567, resource_id: resource_id, user_id: 123)

      expect(ResourceStat.resource_range_stats(start_date, end_date, resource_id, user_id).map(&:unique_visitors)).to eq([123, 234])
    end
  end

  describe ".site_range_stats" do
    let(:start_date) { DateTime.new(2018, 2, 2).in_time_zone }
    let(:end_date) { DateTime.new(2018, 3, 2).in_time_zone }
    let(:user_id) { 123 }
    let(:resource_id) { "199" }

    it 'finds site-wide statistics in a given time range' do
      ResourceStat.create(date: DateTime.new(2018, 2, 4).in_time_zone, unique_visitors: 123)
      ResourceStat.create(date: DateTime.new(2018, 2, 17).in_time_zone, unique_visitors: 234, resource_id: resource_id, user_id: 123)
      ResourceStat.create(date: DateTime.new(2018, 3, 9).in_time_zone, unique_visitors: 567)

      expect(ResourceStat.site_range_stats(start_date, end_date).map(&:unique_visitors)).to eq([123])
    end
  end
end