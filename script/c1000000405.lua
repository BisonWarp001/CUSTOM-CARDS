--The Eraser of Annihilation
local s,id=GetID()
function s.initial_effect(c)
    --Must be Special Summoned (from your Extra Deck) by sending 1 "The Wicked Eraser" + 1 Divine Evolution
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

    --Prevent cards/effects activation when Special Summoned
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
        Duel.SetChainLimitTillChainEnd(aux.FALSE)
    end)
    c:RegisterEffect(e2)

    --Cannot be tributed, targeted, or destroyed by opponent's effects
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_UNRELEASABLE_SUM)
    e3:SetValue(1)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e4:SetValue(aux.tgoval)
    c:RegisterEffect(e4)
    local e5=e3:Clone()
    e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e5:SetValue(function(e,re,rp) return rp~=e:GetHandlerPlayer() end)
    c:RegisterEffect(e5)

    --Unaffected by non-DIVINE monsters
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_SINGLE)
    e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e6:SetRange(LOCATION_MZONE)
    e6:SetCode(EFFECT_IMMUNE_EFFECT)
    e6:SetValue(s.immval)
    c:RegisterEffect(e6)

    --Gain 1000 ATK/DEF per card opponent controls
    local e7=Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_SINGLE)
    e7:SetCode(EFFECT_SET_ATTACK_FINAL)
    e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_REPEAT+EFFECT_FLAG_DELAY)
    e7:SetRange(LOCATION_MZONE)
    e7:SetValue(s.atkval)
    c:RegisterEffect(e7)
    local e8=e7:Clone()
    e8:SetCode(EFFECT_SET_DEFENSE_FINAL)
    e8:SetValue(s.defval)
    c:RegisterEffect(e8)

    --Banish monster destroyed in battle instead of sending to GY
    local e9=Effect.CreateEffect(c)
    e9:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e9:SetCode(EVENT_BATTLE_DESTROYING)
    e9:SetCondition(aux.bdgcon)
    e9:SetOperation(s.banishop)
    c:RegisterEffect(e9)

    --When sent to GY: send all cards on field to GY
    local e10=Effect.CreateEffect(c)
    e10:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e10:SetCode(EVENT_TO_GRAVE)
    e10:SetCondition(s.gycon)
    e10:SetOperation(s.gyop)
    c:RegisterEffect(e10)

    --When leaves field: Special Summon Eraser or add Divine Evolution
    local e11=Effect.CreateEffect(c)
    e11:SetDescription(aux.Stringid(id,0))
    e11:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e11:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e11:SetCode(EVENT_LEAVE_FIELD)
    e11:SetProperty(EFFECT_FLAG_DELAY)
    e11:SetCountLimit(1,{id,1})
    e11:SetTarget(s.lftg)
    e11:SetOperation(s.lfop)
    c:RegisterEffect(e11)
end

--Immune to non-DIVINE monster effects
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

--Materials, summon condition
function s.spfilter1(c) return c:IsCode(57793869) and c:IsAbleToGraveAsCost() end -- The Wicked Eraser
function s.spfilter2(c) return c:IsCode(7373632) and c:IsAbleToGraveAsCost() end -- Divine Evolution
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
        and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local wc=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local evo=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
    Duel.SendtoGrave(Group.FromCards(wc,evo),REASON_COST+REASON_MATERIAL)
end

--ATK/DEF gain
function s.atkval(e,c)
    return c:GetControler()==e:GetHandlerPlayer()
        and Duel.GetFieldGroupCount(1-c:GetControler(),LOCATION_ONFIELD,0)*1000+c:GetBaseAttack()
        or c:GetBaseAttack()
end
function s.defval(e,c)
    return c:GetControler()==e:GetHandlerPlayer()
        and Duel.GetFieldGroupCount(1-c:GetControler(),LOCATION_ONFIELD,0)*1000+c:GetBaseDefense()
        or c:GetBaseDefense()
end

--Banish monster destroyed
function s.banishop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetHandler():GetBattleTarget()
    if tc and tc:IsRelateToBattle() then
        Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
    end
end

--Sent to GY
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsReason(REASON_DESTROY)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
    if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT) end
end

--Leave field: revive or add
function s.revfilter(c,e,tp) return c:IsCode(57793869) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) end
function s.evofilter(c) return c:IsCode(7373632) and c:IsAbleToHand() end
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
        op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
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
        if tc then
            Duel.SendtoHand(tc,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,tc)
        end
    end
end
