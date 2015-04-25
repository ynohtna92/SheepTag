function mining_scythe_on_attack( keys )
    local target = keys.target
    local caster = keys.caster

    print("yes!")
    print(caster, target)

    if not target:IsAlive() then
        print("dead", target:GetHealth())
    else
        print("alive", target:GetHealth())
    end

end