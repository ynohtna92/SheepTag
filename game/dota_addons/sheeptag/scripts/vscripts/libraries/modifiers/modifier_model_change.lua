modifier_model_change_wolf = class({})

function modifier_model_change_wolf:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MODEL_CHANGE,
    }

    return funcs
end

function modifier_model_change_wolf:GetModifierModelChange()
    return "models/heroes/lycan/lycan_wolf.vmdl"
end

function modifier_model_change_wolf:IsHidden()
    return true
end

modifier_model_change_sheep = class({})

function modifier_model_change_sheep:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MODEL_CHANGE,
    }

    return funcs
end

function modifier_model_change_sheep:GetModifierModelChange()
    return "models/courier/defense3_sheep/defense3_sheep.mdl"
end

function modifier_model_change_sheep:IsHidden()
    return true
end