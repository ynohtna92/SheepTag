modifier_shepherd_illusion_begin = class({})

function modifier_shepherd_illusion_begin:CheckState() 
    local state = {
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
    }

    return state
end

function modifier_shepherd_illusion_begin:IsHidden()
	return true
end