modifier_no_collision = class({})

function modifier_no_collision:CheckState() 
  local state = {
      [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
  }

  return state
end

function modifier_no_collision:IsHidden()
    return true
end