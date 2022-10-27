# frozen_string_literal: true

require_relative "test_helper"



class Entity
  include BuffrMixin

  attr_accessor :max_health
  attr_accessor :health
  attr_accessor :armor
  attr_accessor :alive

  attr_accessor :mana
  attr_accessor :attack_damage

  def initialize(max_health, health = nil, armor = 0, mana = 100, attack_damage = 10)
    @max_health = max_health
    @health = health == nil ? max_health : health
    @alive = true

    @armor = armor

    @mana = mana
    @attack_damage = attack_damage
  end

  def update(deltatime)
    update_effects(deltatime)
  end

  def take_damage(value)
    @health -= value
    if @health <= 0 then
      self.die()
    end
  end

  def die()
    self.apply_dispel("death")
    @alive = false
    self.on_death()
  end

  def on_death()
    puts(self.to_s() + " died.")
  end
end


class Weakness < Buffr::GenericEffect
  def max_duration
    5.0
  end

  def on_apply()
    @object.attack_damage *= 0.5
  end

  def on_clear()
    @object.attack_damage *= 2.0
  end
end


class Poison < Buffr::ExtendingEffect
  def max_duration
    5.0
  end

  def on_update(deltatime)
    @object.take_damage(deltatime * 5)
  end
end

class ManaLeak < Buffr::MultiEffect
  def max_duration
    2.0
  end

  def on_apply()
    @object.mana *= 0.5
  end

  def on_clear()
    @object.mana *= 2.0
  end
end

class Corrosion < Buffr::StackingEffect
  def max_duration
    5.0
  end

  def on_apply()
    @object.armor -= 1
  end

  def on_clear()
    @object.armor += 1
  end
end

class PermanentBonusDamage < Buffr::StackingEffect
  def max_duration
    Float::INFINITY
  end

  def on_apply()
    @object.attack_damage += 2
  end
end


class TestBuffr < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Buffr::VERSION
  end

  def test_it_does_something_useful
    assert true # >:)
  end

  def test_generic
    ent = Entity.new(100)
    ent.apply_effect(Weakness.new())
    assert ent.effects[Weakness].percent_left == 1.0
    
    assert ent.attack_damage == 5.0
    ent.update(3.0)
    assert ent.effects[Weakness].percent_left == 3.0/5.0
    assert ent.attack_damage == 5.0
    ent.update(3.0)
    assert ent.attack_damage == 10.0
  end

  def test_extending
    ent = Entity.new(100)
    ent.apply_effect(Poison.new())
    ent.update(2.0)
    assert ent.effects[Poison].percent_left == 3.0/5.0
    ent.apply_effect(Poison.new())
    assert ent.effects[Poison].percent_left == 1.0 + 3.0/5.0
    ent.update(1.0)
    ent.update(10.0)
    assert ent.health == 50.0
  end

  def test_multi
    ent = Entity.new(100)
    ent.apply_effect(ManaLeak.new())
    assert ent.mana == 50.0
    ent.update(1.0)
    ent.apply_effect(ManaLeak.new())
    assert ent.mana == 25.0
    ent.update(1.0)
    assert ent.mana == 50.0
    ent.apply_effect(ManaLeak.new())
    assert ent.mana == 25.0
    ent.update(6.0)
    assert ent.mana == 100.0
    ent.apply_effect(ManaLeak.new())
    assert ent.mana == 50.0
  end

  def test_stacking
    ent = Entity.new(100, 100, 10)
    ent.apply_effect(Corrosion.new())
    
    assert ent.armor == 9.0
    ent.update(1.0)
    ent.apply_effect(Corrosion.new())
    assert ent.armor == 8.0
    ent.update(1.0)
    ent.apply_effect(Corrosion.new())
    assert ent.armor == 7.0
    ent.update(6.0)
    assert ent.armor == 10.0
  end

  
  def test_permanent
    ent = Entity.new(100, 100, 10)
    ent.apply_effect(PermanentBonusDamage.new())

    assert ent.attack_damage == 12.0
    ent.update(999999999)
    assert ent.attack_damage == 12.0
    ent.apply_effect(PermanentBonusDamage.new())
    assert ent.effects[PermanentBonusDamage].percent_left == 1.0
    ent.apply_effect(PermanentBonusDamage.new())
    assert ent.attack_damage == 16.0

    assert ent.effects[PermanentBonusDamage].percent_left == 1.0
  end
end
