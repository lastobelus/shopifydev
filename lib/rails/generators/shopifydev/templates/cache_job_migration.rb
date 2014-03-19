class CreateCacheJobs < ActiveRecord::Migration
  def change
    create_table :cache_jobs do
      t.string  :jid, index: true
      t.integer :new_ids, array: true, default: []
      t.integer :updated_ids, array: true, default: []
      t.string  :state, default: 'requested'
    end
  end
end
