# frozen_string_literal: true

require_relative "buffr/version"


module BuffrMixin
  def update_effects(deltatime)
    self.validate_effects()
    @effects.each do |cls, effect|
      effect.update(deltatime)
    end
  end

  def apply_effect(effect)
    self.validate_effects()
    old_effect = @effects[effect.class]
    effect.apply_to(self, old_effect)
  end

  def apply_dispel(dispel_group)
    self.validate_effects()
    @effects.each do |cls, effect|
      if effect.dispel_groups.include?(dispel_group) then
        effect.dispel(dispel_group)
      end
    end
  end

  def validate_effects()
    if @effects == nil then @effects = {} end
  end

  def effects()
    self.validate_effects()
    return @effects
  end
end

module Buffr
  class Error < StandardError; end

  # Overrides the previous effect
  class BaseEffect
    @@dispel_groups = []

    attr_accessor :object
    attr_accessor :duration

    def initialize()
      @duration = self.max_duration
    end

    def max_duration
      return 10.0
    end

    def dispel_groups
      @@dispel_groups
    end

    def update(deltatime)
      passed = [deltatime, @duration].min
      @duration -= passed
      self.on_update(passed)
      if @duration <= 0.0 then
        self.timeout()
      end
    end

    def timeout()
      self.on_timeout()
      self.on_clear()
      self.remove()
    end

    def dispel(dispel_group)
      self.on_dispel(dispel_group)
      self.on_clear()
      self.remove()
    end

    def remove()
      @object.effects.delete(self.class)
      self.on_remove()
    end

    def apply_to(object, old_effect)
      @object = object
      @object.effects[self.class] = self
      self.on_apply()
    end

    def percent_left
      if @duration.infinite? then return 1.0 end
      @duration / self.max_duration
    end



    # Event handlers
    def on_apply() end
    def on_update(deltatime) end
    def on_dispel(dispel_group) end
    def on_timeout() end

    # When the effects of the effect should be reversed
    def on_clear() end

    # When effect needs to be removed from the object
    def on_remove() end

  end

  # Refreshes effect duration
  class GenericEffect < BaseEffect
    def apply_to(object, old_effect)
      @object = object
      @object.effects[self.class] = self

      old_duration = old_effect == nil ? 0.0 : old_effect.duration
      @duration = [@duration, old_duration].max

      if old_effect == nil then self.on_apply() end
    end
  end

  # Adds the duration
  class ExtendingEffect < BaseEffect
    def apply_to(object, old_effect)
      @object = object
      @object.effects[self.class] = self

      old_duration = old_effect == nil ? 0.0 : old_effect.duration
      @duration = @duration + old_duration

      if old_effect == nil then self.on_apply() end
    end
  end

  # Allows for multiple effects to be applied
  class MultiEffect < GenericEffect
    attr_accessor :count

    def apply_to(object, old_effect)
      if old_effect.nil? then
        @count = 1
      else
        @count = old_effect.count + 1
      end

      @object = object
      @object.effects[self.class] = self

      @duration = old_effect == nil ? self.max_duration : old_effect.duration
      self.on_apply()
    end

    def update(deltatime)
      while deltatime > 0.0 do
        passed = [deltatime, @duration].min
        @duration -= passed
        deltatime -= passed
        self.on_update(passed)
        if @duration <= 0.0 then
          self.timeout()
        end
        if @count == 0 then
          return
        end
      end
    end

    def timeout()
      self.on_timeout()
      self.on_clear()
      @count -= 1
      if @count == 0 then
        self.remove()
      else
        @duration = self.max_duration
      end
    end
  end

  # Allow for effects to stack and refresh the duration
  class StackingEffect < GenericEffect
    attr_accessor :count

    def apply_to(object, old_effect)
      if old_effect.nil? then
        @count = 1
      else
        @count = old_effect.count + 1
      end

      @object = object
      @object.effects[self.class] = self

      old_duration = old_effect == nil ? 0.0 : old_effect.duration
      @duration = [@duration, old_duration].max

      self.on_apply()
    end

    def timeout()
      self.on_timeout()
      @count.times do self.on_clear end
      self.remove()
    end
  end

end
