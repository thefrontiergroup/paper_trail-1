module PaperTrail
  # Represents the "paper trail" for a single record.
  class RecordTrail
    def initialize(record)
      @record = record
    end

    # Utility method for reifying. Anything executed inside the block will
    # appear like a new record.
    def appear_as_new_record
      @record.instance_eval {
        alias :old_new_record? :new_record?
        alias :new_record? :present?
      }
      yield
      @record.instance_eval { alias :new_record? :old_new_record? }
    end

    # Invoked after rollbacks to ensure versions records are not created for
    # changes that never actually took place. Optimization: Use lazy `reset`
    # instead of eager `reload` because, in many use cases, the association will
    # not be used.
    def clear_rolled_back_versions
      versions.reset
    end

    def enabled_for_model?
      @record.class.paper_trail.enabled?
    end

    # Returns true if this instance is the current, live one;
    # returns false if this instance came from a previous version.
    def live?
      source_version.nil?
    end

    # Returns the object (not a Version) as it became next.
    # NOTE: if self (the item) was not reified from a version, i.e. it is the
    #  "live" item, we return nil.  Perhaps we should return self instead?
    def next_version
      subsequent_version = source_version.next
      subsequent_version ? subsequent_version.reify : @record.class.find(@record.id)
    rescue # TODO: Rescue something more specific
      nil
    end

    # Returns who put `@record` into its current state.
    def originator
      (source_version || versions.last).try(:whodunnit)
    end

    # Returns the object (not a Version) as it was most recently.
    def previous_version
      (source_version ? source_version.previous : versions.last).try(:reify)
    end

    def record_create
      return unless @record.paper_trail_switched_on?
      data = {
        event: @record.paper_trail_event || "create",
        whodunnit: PaperTrail.whodunnit
      }
      if @record.respond_to?(:updated_at)
        data[PaperTrail.timestamp_field] = @record.updated_at
      end
      if @record.pt_record_object_changes? && @record.changed_notably?
        data[:object_changes] = @record.pt_recordable_object_changes
      end
      @record.add_transaction_id_to(data)
      versions_assoc = @record.send(@record.class.versions_association_name)
      version = versions_assoc.create! @record.merge_metadata(data)
      @record.update_transaction_id(version)
      @record.save_associations(version)
    end

    def source_version
      version
    end

    # Mimics the `touch` method from `ActiveRecord::Persistence`, but also
    # creates a version. A version is created regardless of options such as
    # `:on`, `:if`, or `:unless`.
    #
    # TODO: look into leveraging the `after_touch` callback from
    # `ActiveRecord` to allow the regular `touch` method to generate a version
    # as normal. May make sense to switch the `record_update` method to
    # leverage an `after_update` callback anyways (likely for v4.0.0)
    def touch_with_version(name = nil)
      unless @record.persisted?
        raise ActiveRecordError, "can not touch on a new record object"
      end
      attributes = @record.send :timestamp_attributes_for_update_in_model
      attributes << name if name
      current_time = @record.send :current_time_from_proper_timezone
      attributes.each { |column|
        @record.send(:write_attribute, column, current_time)
      }
      @record.record_update(true) unless will_record_after_update?
      @record.save!(validate: false)
    end

    # Returns the object (not a Version) as it was at the given timestamp.
    def version_at(timestamp, reify_options = {})
      # Because a version stores how its object looked *before* the change,
      # we need to look for the first version created *after* the timestamp.
      v = versions.subsequent(timestamp, true).first
      return v.reify(reify_options) if v
      @record unless @record.destroyed?
    end

    # Returns the objects (not Versions) as they were between the given times.
    def versions_between(start_time, end_time)
      versions = send(@record.class.versions_association_name).between(start_time, end_time)
      versions.collect { |version|
        version_at(version.send(PaperTrail.timestamp_field))
      }
    end

    # Executes the given method or block without creating a new version.
    def without_versioning(method = nil)
      paper_trail_was_enabled = enabled_for_model?
      @record.class.paper_trail.disable
      if method
        if respond_to?(method)
          public_send(method)
        else
          @record.send(method)
        end
      else
        yield @record
      end
    ensure
      @record.class.paper_trail.enable if paper_trail_was_enabled
    end

    # Temporarily overwrites the value of whodunnit and then executes the
    # provided block.
    def whodunnit(value)
      raise ArgumentError, "expected to receive a block" unless block_given?
      current_whodunnit = PaperTrail.whodunnit
      PaperTrail.whodunnit = value
      yield @record
    ensure
      PaperTrail.whodunnit = current_whodunnit
    end

    private

    # Returns true if `save` will cause `record_update`
    # to be called via the `after_update` callback.
    def will_record_after_update?
      on = @record.paper_trail_options[:on]
      on.nil? || on.include?(:update)
    end

    def version
      @record.public_send(@record.class.version_association_name)
    end

    def versions
      @record.public_send(@record.class.versions_association_name)
    end
  end
end
