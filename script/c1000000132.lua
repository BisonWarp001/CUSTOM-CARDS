--Egyptian Clone Slime
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()

    ---------------------------------------------------------
    -- Fusion Summon: permite 1 o 2 materiales
    ---------------------------------------------------------
    Fusion.AddProcMixRep(c,true,true,
        s.matfilter,1,2)

    ---------------------------------------------------------
    -- Alternative Summon (tributando materiales del campo)
    ---------------------------------------------------------
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCondition(s.hspcon)
    e0:SetTarget(s.hsptg)
    e0:SetOperation(s.hspop)
    c:RegisterEffect(e0)

    ---------------------------------------------------------
    -- Cannot be destroyed by battle or effects
    ---------------------------------------------------------
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    local e2=e1:Clone()
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    c:RegisterEffect(e2)

    ---------------------------------------------------------
    -- Copy ATK/DEF of opponent monster during damage calc
    ---------------------------------------------------------
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetOperation(s.atkop)
    c:RegisterEffect(e3)
end

-------------------------------------------------------------
-- MATERIAL FILTER: acepta WATER LV10+ y Aqua
-- si un monstruo es AMBOS → puede usarse solo
-------------------------------------------------------------
function s.matfilter(c,fc,sumtype,tp)
    return (c:IsAttribute(ATTRIBUTE_WATER) and c:GetLevel()>=10)
        or c:IsRace(RACE_AQUA)
end

-------------------------------------------------------------
-- CAMPO: Invocación alternativa
-- Permite:
-- 1 monstruo que cumpla ambas condiciones
-- O 1 WATER 10+ + 1 Aqua separados
-------------------------------------------------------------
function s.hspcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)

    local water10 = mg:FilterCount(function(tc)
        return tc:IsAttribute(ATTRIBUTE_WATER) and tc:GetLevel()>=10
    end,nil)

    local aqua = mg:FilterCount(function(tc)
        return tc:IsRace(RACE_AQUA)
    end,nil)

    local both = mg:FilterCount(function(tc)
        return tc:IsAttribute(ATTRIBUTE_WATER)
            and tc:GetLevel()>=10
            and tc:IsRace(RACE_AQUA)
    end,nil)

    return both>=1 or (water10>=1 and aqua>=1)
end

function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)

    -- opción 1: usar 1 solo monstruo
    local both = mg:Filter(function(tc)
        return tc:IsAttribute(ATTRIBUTE_WATER) and tc:GetLevel()>=10 and tc:IsRace(RACE_AQUA)
    end,nil)

    if #both>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
        local g = both:Select(tp,1,1,nil)
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end

    -- opción 2: usar 2 monstruos
    local water = mg:Filter(function(tc)
        return tc:IsAttribute(ATTRIBUTE_WATER) and tc:GetLevel()>=10
    end,nil)

    local aqua = mg:Filter(Card.IsRace,nil,RACE_AQUA)

    if #water<1 or #aqua<1 then return false end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local m1 = water:Select(tp,1,1,nil)

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local m2 = aqua:Select(tp,1,1,nil)

    local g=Group.CreateGroup()
    g:Merge(m1)
    g:Merge(m2)
    g:KeepAlive()
    e:SetLabelObject(g)
    return true
end

function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
    local g=e:GetLabelObject()
    Duel.Release(g,REASON_COST|REASON_MATERIAL)
    g:DeleteGroup()
end
-------------------------------------------------------------
-- COPY ATK/DEF (ambos se igualan al ATK del monstruo rival)
-------------------------------------------------------------
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    if not bc then return end

    -- Tomar solo el ATK del monstruo enemigo
    local atk=bc:GetAttack()
    if atk<0 then atk=0 end

    -- Set final ATK = ATK del monstruo oponente
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_ATTACK_FINAL)
    e1:SetValue(atk)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
    c:RegisterEffect(e1)

    -- Set final DEF = ATK del monstruo oponente
    local e2=e1:Clone()
    e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
    e2:SetValue(atk)
    c:RegisterEffect(e2)
end

