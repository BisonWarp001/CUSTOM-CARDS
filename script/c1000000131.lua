--Egyptian Divine Slime
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
    -- Cannot be destroyed by battle
    ---------------------------------------------------------
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    ---------------------------------------------------------
    -- If sent to GY by card effect → Special Summon itself
    ---------------------------------------------------------
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCondition(s.spcon2)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)
end

-------------------------------------------------------------
-- MATERIAL FILTER: WATER Lv10+ o Aqua
-- Si un monstruo es ambos → Puede ser el único material
-------------------------------------------------------------
function s.matfilter(c,fc,sumtype,tp)
    return (c:IsAttribute(ATTRIBUTE_WATER) and c:GetLevel()>=10)
        or c:IsRace(RACE_AQUA)
end

-------------------------------------------------------------
-- CAMPO: Invocación alternativa
-------------------------------------------------------------
function s.hspcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)

    -- WATER Lv10+
    local water10 = mg:FilterCount(function(tc)
        return tc:IsAttribute(ATTRIBUTE_WATER) and tc:GetLevel()>=10
    end,nil)

    -- Aqua
    local aqua = mg:FilterCount(function(tc)
        return tc:IsRace(RACE_AQUA)
    end,nil)

    -- Ambos (permite usar solo 1)
    local both = mg:FilterCount(function(tc)
        return tc:IsAttribute(ATTRIBUTE_WATER)
        and tc:GetLevel()>=10
        and tc:IsRace(RACE_AQUA)
    end,nil)

    return both>=1 or (water10>=1 and aqua>=1)
end

function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)

    -- opción 1: usar 1 solo monstruo (cumple ambas)
    local both = mg:Filter(function(tc)
        return tc:IsAttribute(ATTRIBUTE_WATER)
        and tc:GetLevel()>=10
        and tc:IsRace(RACE_AQUA)
    end,nil)

    if #both>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
        local g=both:Select(tp,1,1,nil)
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end

    -- opción 2: usar 2 materiales distintos
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
-- Reborn itself if sent by effect
-------------------------------------------------------------
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_EFFECT)
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
           and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end
