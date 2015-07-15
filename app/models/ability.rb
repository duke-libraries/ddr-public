class Ability < Ddr::Auth::Ability

  self.ability_definitions += [ PublishedAbilityDefinitions ]

end
