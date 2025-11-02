--Ra, the God of the Sun
local s,id=GetID()
function s.initial_effect(c)
    --Fusion-like Special Summon: any Ra + Divine Evolution
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

    --Prevent cards/effects activation when Special Summoned + Optional LP payment
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id)
    e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return true end
        Duel.SetChainLimitTillChainEnd(s.genchainlm(e:GetHandler()))
    end)
    e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
        local c=e:GetHandler()
        if not (c:IsRelateToEffect(e) and c:IsFaceup()) then return end
        local lp=Duel.GetLP(tp)-100
        if lp>0 and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
            Duel.PayLPCost(tp,lp)
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(lp)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            c:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_UPDATE_DEFENSE)
            c:RegisterEffect(e2)
        end
    end)
    c:RegisterEffect(e2)

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
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_SINGLE)
    e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e6:SetCode(EFFECT_IMMUNE_EFFECT)
    e6:SetRange(LOCATION_MZONE)
    e6:SetValue(s.immval)
    c:RegisterEffect(e6)

    --Quick Effect: Tribute monsters to gain ATK/DEF
    local e7=Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id,1))
    e7:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_RELEASE)
    e7:SetType(EFFECT_TYPE_QUICK_O)
    e7:SetCode(EVENT_FREE_CHAIN)
    e7:SetRange(LOCATION_MZONE)
    e7:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e7:SetCost(s.tribute_cost)
    e7:SetOperation(s.tribute_op)
    c:RegisterEffect(e7)

    --Quick Effect: pay 1000 LP to send 1 monster on field to GY
    local e8=Effect.CreateEffect(c)
    e8:SetDescription(aux.Stringid(id,2))
    e8:SetCategory(CATEGORY_TOGRAVE)
    e8:SetType(EFFECT_TYPE_QUICK_O)
    e8:SetCode(EVENT_FREE_CHAIN)
    e8:SetRange(LOCATION_MZONE)
    e8:SetCost(s.lp1000_cost)
    e8:SetTarget(s.tg_target)
    e8:SetOperation(s.tg_operation)
    c:RegisterEffect(e8)

    --When leaves field: Special Summon Ra or add Divine Evolution
    local e9=Effect.CreateEffect(c)
    e9:SetDescription(aux.Stringid(id,7)) -- 7 = Special Summon Ra
    e9:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e9:SetCode(EVENT_LEAVE_FIELD)
    e9:SetProperty(EFFECT_FLAG_DELAY)
    e9:SetCountLimit(1,{id,7})
    e9:SetTarget(s.lftg)
    e9:SetOperation(s.lfop)
    c:RegisterEffect(e9)
end

-- Helper to block other activations during Special Summon
function s.genchainlm(c)
    return function(e,rp,tp)
        return e:GetHandler()==c
    end
end

-- Special Summon condition: any Ra + Divine Evolution
function s.spfilter_ra(c)
    return c:IsCode(10000010,10000080,10000090) and c:IsAbleToGraveAsCost()
end
function s.spfilter_evo(c)
    return c:IsCode(7373632) and c:IsAbleToGraveAsCost()
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
        and Duel.IsExistingMatchingCard(s.spfilter_ra,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.spfilter_evo,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local rc=Duel.SelectMatchingCard(tp,s.spfilter_ra,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local evo=Duel.SelectMatchingCard(tp,s.spfilter_evo,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
    Duel.SendtoGrave(Group.FromCards(rc,evo),REASON_COST+REASON_MATERIAL)
end

-- Quick Effect: Tribute monsters (excluding itself) to gain their combined ATK/DEF
function s.tribute_cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroup(tp,function(c) return c~=e:GetHandler() end,1,nil) end
    local g=Duel.SelectReleaseGroup(tp,function(c) return c~=e:GetHandler() end,1,99,nil)
    local atkSum, defSum = 0, 0
    for tc in aux.Next(g) do
        atkSum = atkSum + math.max(tc:GetAttack(),0)
        defSum = defSum + math.max(tc:GetDefense(),0)
    end
    e:SetLabelObject({atk=atkSum, defn=defSum})
    Duel.Release(g,REASON_COST)
end

function s.tribute_op(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local lbl = e:GetLabelObject()
    if not c:IsRelateToEffect(e) or (lbl.atk<=0 and lbl.defn<=0) then return end
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(lbl.atk)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    e2:SetValue(lbl.defn)
    c:RegisterEffect(e2)
end

-- Pay 1000 LP to send 1 monster on field to GY
function s.lp1000_cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,1000) end
    Duel.PayLPCost(tp,1000)
end
function s.tg_target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_MZONE)
end
function s.tg_operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT) end
end

-- Leave field: Special Summon Ra or add Divine Evolution
function s.revfilter(c,e,tp)
    return c:IsCode(10000010,10000080,10000090) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
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
        op=Duel.SelectOption(tp,aux.Stringid(id,7),aux.Stringid(id,8))
    elseif b1 then
        op=0
    elseif b2 then
        op=1
    else return end
    if op==0 then
        local tc=Duel.SelectMatchingCard(tp,s.revfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
        if tc then
            if Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)~=0 then
                -- Give 4000 ATK/DEF
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_SET_ATTACK_FINAL)
                e1:SetValue(4000)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                tc:RegisterEffect(e1)
                local e2=e1:Clone()
                e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
                tc:RegisterEffect(e2)
            end
        end
    else
        local tc=Duel.SelectMatchingCard(tp,s.evofilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil):GetFirst()
        if tc then
            Duel.SendtoHand(tc,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,tc)
        end
    end
end

------------------------------------------------------------
-- Unaffected by non-DIVINE monsters
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