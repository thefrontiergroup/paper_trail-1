require "active_support/core_ext/object" # provides the `try` method
require "paper_trail/attribute_serializers/legacy_active_record_shim"
require "paper_trail/attribute_serializers/object_attribute"
require "paper_trail/attribute_serializers/object_changes_attribute"
require "paper_trail/model_config"
require "paper_trail/record_trail"

module PaperTrail
  # Extensions to `ActiveRecord::Base`.  See `frameworks/active_record.rb`.
  # It is our goal to have the smallest possible footprint here, because
  # `ActiveRecord::Base` is a very crowded namespace! That is why we introduced
  # `.paper_trail` and `#paper_trail`.
  module Model
    def self.included(base)
      base.send :extend, ClassMethods
    end

    # :nodoc:
    module ClassMethods
      # Declare this in your model to track every create, update, and destroy.
      # Each version of the model is available in the `versions` association.
      #
      # Options:
      #
      # - :on - The events to track (optional; defaults to all of them). Set
      #   to an array of `:create`, `:update`, `:destroy` as desired.
      # - :class_name - The name of a custom Version class.  This class should
      #   inherit from `PaperTrail::Version`.
      # - :ignore - An array of attributes for which a new `Version` will not be
      #   created if only they change. It can also aceept a Hash as an
      #   argument where the key is the attribute to ignore (a `String` or
      #   `Symbol`), which will only be ignored if the value is a `Proc` which
      #   returns truthily.
      # - :if, :unless - Procs that allow to specify conditions when to save
      #   versions for an object.
      # - :only - Inverse of `ignore`. A new `Version` will be created only
      #   for these attributes if supplied it can also aceept a Hash as an
      #   argument where the key is the attribute to track (a `String` or
      #   `Symbol`), which will only be counted if the value is a `Proc` which
      #   returns truthily.
      # - :skip - Fields to ignore completely.  As with `ignore`, updates to
      #   these fields will not create a new `Version`.  In addition, these
      #   fields will not be included in the serialized versions of the object
      #   whenever a new `Version` is created.
      # - :meta - A hash of extra data to store. You must add a column to the
      #   `versions` table for each key. Values are objects or procs (which
      #   are called with `self`, i.e. the model with the paper trail).  See
      #   `PaperTrail::Controller.info_for_paper_trail` for how to store data
      #   from the controller.
      # - :versions - The name to use for the versions association.  Default
      #   is `:versions`.
      # - :version - The name to use for the method which returns the version
      #   the instance was reified from. Default is `:version`.
      # - :save_changes - Whether or not to save changes to the object_changes
      #   column if it exists. Default is true
      # - :join_tables - If the model has a has_and_belongs_to_many relation
      #   with an unpapertrailed model, passing the name of the association to
      #   the join_tables option will paper trail the join table but not save
      #   the other model, allowing reification of the association but with the
      #   other models latest state (if the other model is paper trailed, this
      #   option does nothing)
      #
      # @api public
      def has_paper_trail(options = {})
        paper_trail.setup(options)
      end

      # @api public
      def paper_trail
        ::PaperTrail::ModelConfig.new(self)
      end

      # @api private
      def paper_trail_deprecate(new_method, old_method = nil)
        old = old_method.nil? ? new_method : old_method
        msg = format("Use paper_trail.%s instead of %s", new_method, old)
        ::ActiveSupport::Deprecation.warn(msg, caller(2))
      end

      # @api public
      def paper_trail_on_destroy(*args)
        paper_trail_deprecate "on_destroy", "paper_trail_on_destroy"
        paper_trail_on_destroy(*args)
      end

      # @api public
      def paper_trail_on_update
        paper_trail_deprecate "on_update", "paper_trail_on_update"
        paper_trail.on_update
      end

      # @api public
      def paper_trail_on_create
        paper_trail_deprecate "on_create", "paper_trail_on_create"
        paper_trail.on_create
      end

      # @api public
      def paper_trail_off!
        paper_trail_deprecate "disable", "paper_trail_off!"
        paper_trail.disable
      end

      # @api public
      def paper_trail_on!
        paper_trail_deprecate "enable", "paper_trail_on!"
        paper_trail.enable
      end

      # @api public
      def paper_trail_enabled_for_model?
        paper_trail_deprecate "enabled?", "paper_trail_enabled_for_model?"
        paper_trail.enabled?
      end

      # @api private
      def paper_trail_version_class
        paper_trail_deprecate "version_class", "paper_trail_version_class"
        paper_trail.version_class
      end
    end

    # Wrap the following methods in a module so we can include them only in the
    # ActiveRecord models that declare `has_paper_trail`.
    module InstanceMethods
      def paper_trail
        ::PaperTrail::RecordTrail.new(self)
      end

      def live?
        self.class.paper_trail_deprecate "live?"
        paper_trail.live?
      end

      def paper_trail_originator
        self.class.paper_trail_deprecate "originator", "paper_trail_originator"
        paper_trail.originator
      end

      def originator
        self.class.paper_trail_deprecate "originator"
        paper_trail.originator
      end

      def clear_rolled_back_versions
        self.class.paper_trail_deprecate "clear_rolled_back_versions"
        paper_trail.clear_rolled_back_versions
      end

      def source_version
        self.class.paper_trail_deprecate "source_version"
        paper_trail.source_version
      end

      def version_at(*args)
        self.class.paper_trail_deprecate "version_at"
        paper_trail.version_at(*args)
      end

      def versions_between(start_time, end_time, _reify_options = {})
        self.class.paper_trail_deprecate "versions_between"
        paper_trail.versions_between(start_time, end_time)
      end

      def previous_version
        self.class.paper_trail_deprecate "previous_version"
        paper_trail.previous_version
      end

      def next_version
        self.class.paper_trail_deprecate "next_version"
        paper_trail.next_version
      end

      def paper_trail_enabled_for_model?
        self.class.paper_trail_deprecate "enabled_for_model?", "paper_trail_enabled_for_model?"
        paper_trail.enabled_for_model?
      end

      def without_versioning(method = nil, &block)
        self.class.paper_trail_deprecate "without_versioning"
        paper_trail.without_versioning(method, &block)
      end

      def appear_as_new_record(&block)
        self.class.paper_trail_deprecate "appear_as_new_record"
        paper_trail.appear_as_new_record(&block)
      end

      def whodunnit(value, &block)
        self.class.paper_trail_deprecate "whodunnit"
        paper_trail.whodunnit(value, &block)
      end

      def touch_with_version(name = nil)
        self.class.paper_trail_deprecate "touch_with_version"
        paper_trail.touch_with_version(name)
      end

      # `record_create` is deprecated in favor of `paper_trail.record_create`,
      # but does not yet print a deprecation warning. When the `after_create`
      # callback is registered (by ModelConfig#on_create) we still refer to this
      # method by name, e.g.
      #
      #     @model_class.after_create :record_create, if: :save_version?
      #
      # instead of using the preferred method `paper_trail.record_create`, e.g.
      #
      #     @model_class.after_create { |r| r.paper_trail.record_create if r.save_version?}
      #
      # We still register the callback by name so that, if someone calls
      # `has_paper_trail` twice, the callback will *not* be registered twice.
      # Our own test suite calls `has_paper_trail` many times for the same
      # class.
      #
      # In the future, perhaps we should require that users only set up
      # PT once per class.
      #
      # @deprecated
      def record_create
        paper_trail.record_create
      end

      def record_update(force = nil)
        if paper_trail_switched_on? && (force || changed_notably?)
          data = {
            event: paper_trail_event || "update",
            object: pt_recordable_object,
            whodunnit: PaperTrail.whodunnit
          }
          if respond_to?(:updated_at)
            data[PaperTrail.timestamp_field] = updated_at
          end
          if pt_record_object_changes?
            data[:object_changes] = pt_recordable_object_changes
          end
          add_transaction_id_to(data)
          version = send(self.class.versions_association_name).create merge_metadata(data)
          if version.errors.any?
            log_version_errors(version, :update)
          else
            update_transaction_id(version)
            save_associations(version)
          end
        end
      end

      # Returns a boolean indicating whether to store serialized version diffs
      # in the `object_changes` column of the version record.
      # @api private
      def pt_record_object_changes?
        paper_trail_options[:save_changes] &&
          self.class.paper_trail.version_class.column_names.include?("object_changes")
      end

      # Returns an object which can be assigned to the `object` attribute of a
      # nascent version record. If the `object` column is a postgres `json`
      # column, then a hash can be used in the assignment, otherwise the column
      # is a `text` column, and we must perform the serialization here, using
      # `PaperTrail.serializer`.
      # @api private
      def pt_recordable_object
        if self.class.paper_trail.version_class.object_col_is_json?
          object_attrs_for_paper_trail
        else
          PaperTrail.serializer.dump(object_attrs_for_paper_trail)
        end
      end

      # Returns an object which can be assigned to the `object_changes`
      # attribute of a nascent version record. If the `object_changes` column is
      # a postgres `json` column, then a hash can be used in the assignment,
      # otherwise the column is a `text` column, and we must perform the
      # serialization here, using `PaperTrail.serializer`.
      # @api private
      def pt_recordable_object_changes
        if self.class.paper_trail.version_class.object_changes_col_is_json?
          changes_for_paper_trail
        else
          PaperTrail.serializer.dump(changes_for_paper_trail)
        end
      end

      def changes_for_paper_trail
        notable_changes = changes.delete_if { |k, _v| !notably_changed.include?(k) }
        AttributeSerializers::ObjectChangesAttribute.
          new(self.class).
          serialize(notable_changes)
        notable_changes.to_hash
      end

      # Invoked via`after_update` callback for when a previous version is
      # reified and then saved.
      def clear_version_instance!
        send("#{self.class.version_association_name}=", nil)
      end

      # Invoked via callback when a user attempts to persist a reified
      # `Version`.
      def reset_timestamp_attrs_for_update_if_needed!
        return if paper_trail.live?
        timestamp_attributes_for_update_in_model.each do |column|
          # ActiveRecord 4.2 deprecated `reset_column!` in favor of
          # `restore_column!`.
          if respond_to?("restore_#{column}!")
            send("restore_#{column}!")
          else
            send("reset_#{column}!")
          end
        end
      end

      def record_destroy
        if paper_trail_switched_on? && !new_record?
          data = {
            item_id: id,
            item_type: self.class.base_class.name,
            event: paper_trail_event || "destroy",
            object: pt_recordable_object,
            whodunnit: PaperTrail.whodunnit
          }
          add_transaction_id_to(data)
          version = self.class.paper_trail.version_class.create(merge_metadata(data))
          if version.errors.any?
            log_version_errors(version, :destroy)
          else
            send("#{self.class.version_association_name}=", version)
            send(self.class.versions_association_name).reset
            update_transaction_id(version)
            save_associations(version)
          end
        end
      end

      # Saves associations if the join table for `VersionAssociation` exists.
      def save_associations(version)
        return unless PaperTrail.config.track_associations?
        save_associations_belongs_to(version)
        save_associations_has_and_belongs_to_many(version)
      end

      def save_associations_belongs_to(version)
        self.class.reflect_on_all_associations(:belongs_to).each do |assoc|
          assoc_version_args = {
            version_id: version.id,
            foreign_key_name: assoc.foreign_key
          }

          if assoc.options[:polymorphic]
            associated_record = send(assoc.name) if send(assoc.foreign_type)
            if associated_record && associated_record.class.paper_trail.enabled?
              assoc_version_args[:foreign_key_id] = associated_record.id
            end
          elsif assoc.klass.paper_trail.enabled?
            assoc_version_args[:foreign_key_id] = send(assoc.foreign_key)
          end

          if assoc_version_args.key?(:foreign_key_id)
            PaperTrail::VersionAssociation.create(assoc_version_args)
          end
        end
      end

      def save_associations_has_and_belongs_to_many(version)
        # Use the :added and :removed keys to extrapolate the HABTM associations
        # to before any changes were made
        self.class.reflect_on_all_associations(:has_and_belongs_to_many).each do |a|
          next unless
            self.class.paper_trail_save_join_tables.include?(a.name) ||
                a.klass.paper_trail.enabled?
          assoc_version_args = {
            version_id: version.transaction_id,
            foreign_key_name: a.name
          }
          assoc_ids =
            send(a.name).to_a.map(&:id) +
            (@paper_trail_habtm.try(:[], a.name).try(:[], :removed) || []) -
            (@paper_trail_habtm.try(:[], a.name).try(:[], :added) || [])
          assoc_ids.each do |id|
            PaperTrail::VersionAssociation.create(assoc_version_args.merge(foreign_key_id: id))
          end
        end
      end

      def reset_transaction_id
        PaperTrail.transaction_id = nil
      end

      def merge_metadata(data)
        # First we merge the model-level metadata in `meta`.
        paper_trail_options[:meta].each do |k, v|
          data[k] =
            if v.respond_to?(:call)
              v.call(self)
            elsif v.is_a?(Symbol) && respond_to?(v, true)
              # If it is an attribute that is changing in an existing object,
              # be sure to grab the current version.
              if has_attribute?(v) && send("#{v}_changed?".to_sym) && data[:event] != "create"
                send("#{v}_was".to_sym)
              else
                send(v)
              end
            else
              v
            end
        end

        # Second we merge any extra data from the controller (if available).
        data.merge(PaperTrail.controller_info || {})
      end

      def attributes_before_change
        changed = changed_attributes.select { |k, _v| self.class.column_names.include?(k) }
        attributes.merge(changed)
      end

      # Returns hash of attributes (with appropriate attributes serialized),
      # ommitting attributes to be skipped.
      def object_attrs_for_paper_trail
        attrs = attributes_before_change.except(*paper_trail_options[:skip])
        AttributeSerializers::ObjectAttribute.new(self.class).serialize(attrs)
        attrs
      end

      # Determines whether it is appropriate to generate a new version
      # instance. A timestamp-only update (e.g. only `updated_at` changed) is
      # considered notable unless an ignored attribute was also changed.
      def changed_notably?
        if ignored_attr_has_changed?
          timestamps = timestamp_attributes_for_update_in_model.map(&:to_s)
          (notably_changed - timestamps).any?
        else
          notably_changed.any?
        end
      end

      # An attributed is "ignored" if it is listed in the `:ignore` option
      # and/or the `:skip` option.  Returns true if an ignored attribute has
      # changed.
      def ignored_attr_has_changed?
        ignored = paper_trail_options[:ignore] + paper_trail_options[:skip]
        ignored.any? && (changed & ignored).any?
      end

      def notably_changed
        only = paper_trail_options[:only].dup
        # Remove Hash arguments and then evaluate whether the attributes (the
        # keys of the hash) should also get pushed into the collection.
        only.delete_if do |obj|
          obj.is_a?(Hash) &&
            obj.each { |attr, condition|
              only << attr if condition.respond_to?(:call) && condition.call(self)
            }
        end
        only.empty? ? changed_and_not_ignored : (changed_and_not_ignored & only)
      end

      def changed_and_not_ignored
        ignore = paper_trail_options[:ignore].dup
        # Remove Hash arguments and then evaluate whether the attributes (the
        # keys of the hash) should also get pushed into the collection.
        ignore.delete_if do |obj|
          obj.is_a?(Hash) &&
            obj.each { |attr, condition|
              ignore << attr if condition.respond_to?(:call) && condition.call(self)
            }
        end
        skip = paper_trail_options[:skip]
        changed - ignore - skip
      end

      def paper_trail_switched_on?
        PaperTrail.enabled? &&
          PaperTrail.enabled_for_controller? &&
          paper_trail.enabled_for_model?
      end

      def save_version?
        if_condition = paper_trail_options[:if]
        unless_condition = paper_trail_options[:unless]
        (if_condition.blank? || if_condition.call(self)) && !unless_condition.try(:call, self)
      end

      def add_transaction_id_to(data)
        return unless self.class.paper_trail.version_class.column_names.include?("transaction_id")
        data[:transaction_id] = PaperTrail.transaction_id
      end

      # @api private
      def update_transaction_id(version)
        return unless self.class.paper_trail.version_class.column_names.include?("transaction_id")
        if PaperTrail.transaction? && PaperTrail.transaction_id.nil?
          PaperTrail.transaction_id = version.id
          version.transaction_id = version.id
          version.save
        end
      end

      def log_version_errors(version, action)
        version.logger.warn(
          "Unable to create version for #{action} of #{self.class.name}##{id}: " +
          version.errors.full_messages.join(", ")
        )
      end
    end
  end
end
