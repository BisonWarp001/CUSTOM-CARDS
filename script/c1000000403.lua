--The Wicked Dreadroot of Decay (MIKE CUSTOM)
local s,id=GetID()
function s.initial_effect(c)
    --Must be Special Summoned (from your Extra Deck) by sending 1 The Wicked Dreadroot + Divine Evolution from hand/field to GY
    c:EnableReviveLimit()
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCondition(s.spcon)
    e0:SetOperation(s.spop)
    c:RegisterEffect(e0)

    --Special Summon cannot be negated
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    c:RegisterEffect(e1)

	--Opponent cannot Tribute, target this card by effects
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_RELEASE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,1)
	e3:SetTarget(function(e,c) return c==e:GetHandler() end)
	c:RegisterEffect(e3)

	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)

    --Unaffected by non-DIVINE monsters
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCode(EFFECT_IMMUNE_EFFECT)
    e5:SetValue(s.immval)
    c:RegisterEffect(e5)

    --Halve ATK/DEF of all opponent's monsters while face-up
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD)
    e6:SetCode(EFFECT_SET_ATTACK_FINAL)
    e6:SetRange(LOCATION_MZONE)
    e6:SetTargetRange(0,LOCATION_MZONE)
    e6:SetTarget(function(e,c) return c:IsFaceup() end)
    e6:SetValue(s.atkval)
    c:RegisterEffect(e6)

    local e7=e6:Clone()
    e7:SetCode(EFFECT_SET_DEFENSE_FINAL)
    e7:SetValue(s.defval)
    c:RegisterEffect(e7)

    --Piercing effect
    local e8=Effect.CreateEffect(c)
    e8:SetType(EFFECT_TYPE_SINGLE)
    e8:SetCode(EFFECT_PIERCE)
    c:RegisterEffect(e8)

    --When leaves field: revive Wicked Dreadroot or add Divine Evolution
    local e9=Effect.CreateEffect(c)
    e9:SetDescription(aux.Stringid(id,1))
    e9:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e9:SetCode(EVENT_LEAVE_FIELD)
    e9:SetProperty(EFFECT_FLAG_DELAY)
    e9:SetCountLimit(1,{id,1})
    e9:SetTarget(s.lftg)
    e9:SetOperation(s.lfop)
    c:RegisterEffect(e9)
end

------------------------------------------------------------
-- Summon requirement
function s.spfilter1(c)
	return c:IsCode(62180201) and c:IsAbleToGraveAsCost()
end
function s.spfilter2(c)
	return c:IsCode(7373632) and c:IsAbleToGraveAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local ob=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local evo=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
	local g=Group.FromCards(ob,evo)
	Duel.SendtoGrave(g,REASON_COST+REASON_MATERIAL)
end

------------------------------------------------------------
--Halving ATK/DEF functions
function s.atkval(e,c)
    return math.floor(c:GetAttack()/2)
end
function s.defval(e,c)
    return math.floor(c:GetDefense()/2)
end

------------------------------------------------------------
--Opponent cannot Tribute this card
function s.sumlimit(e,c)
    return not c:IsControler(e:GetHandlerPlayer())
end

------------------------------------------------------------
--When leaves field: revive Wicked Dreadroot or add Divine Evolution
function s.revfilter(c,e,tp)
    return c:IsCode(62180201) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.evofilter(c)
    return c:IsCode(7373632) and c:IsAbleToHand()
end
function s.lftg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and (Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
            or Duel.IsExistingMatchingCard(s.evofilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil))
    end
end
function s.lfop(e,tp,eg,ep,ev,re,r,rp)
    local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    local b2=Duel.IsExistingMatchingCard(s.evofilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
    local op=0
    if b1 and b2 then
        op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
    elseif b1 then
        op=0
    elseif b2 then
        op=1
    else return end

    if op==0 then
        local tc=Duel.SelectMatchingCard(tp,s.revfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
        if tc then Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP) end
    else
        local tc=Duel.SelectMatchingCard(tp,s.evofilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil):GetFirst()
        if tc then Duel.SendtoHand(tc,nil,REASON_EFFECT) Duel.ConfirmCards(1-tp,tc) end
    end
end

------------------------------------------------------------
--Unaffected by non-DIVINE monsters
function s.immval(e,te,c)
    local tc=te:GetOwner()
    -- Inmune a efectos de monstruos de otros excepto DIVINE
    if te:IsMonsterEffect() and c~=tc and not tc:IsAttribute(ATTRIBUTE_DIVINE) then
        return true
    end
    -- No puede ser destruida por Spell/Trap del oponente
    if te:IsSpellTrapEffect() then
        local ex, tg, cat = Duel.GetOperationInfo(0, CATEGORY_DESTROY)
        if ex and tg and tg:IsContains(c) then
            return true
        end
    end
    return false
end