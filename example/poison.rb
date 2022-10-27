require_relative "../lib/buffr"

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
  
        @armor = 5
  
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


class Poison < Buffr::StackingEffect
    @@dispel_groups = ["death", "antidote"]

    def max_duration() 5 end

    def on_update(deltatime)
        @object.take_damage(deltatime * 4 * self.count)
    end
end

ent = Entity.new(100.0, 75.0, 50.0)
ent.apply_effect(Poison.new())

time = 0.0
time_step = 1.0

puts(ent.effects)
while ent.effects.size > 0 do
    ent.update(time_step)
    
    if [3.0, 4.0].include?(time) then
        ent.apply_effect(Poison.new())
    end

    if time == 7.0 then
        ent.apply_dispel("antidote")
    end

    puts(ent.effects)
    time += time_step
end

puts("HP: " + ent.health.to_s, "Mana: " + ent.mana.to_s)
