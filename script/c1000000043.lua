--Nordic Horror - Ouroboros Break
local s,id=GetID()
function s.initial_effect(c)

    --① Take control of 1 opponent's Effect Monster, negate its effects
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_CONTROL+CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCondition(s.condition1)
    e1:SetTarget(s.target1)
    e1:SetOperation(s.operation1)
    c:RegisterEffect(e1)

    --Destroy trap if linked monster leaves the field
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetCondition(s.descon)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)

    --② When this card is destroyed, add Jormungardr
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end

--Condition: you control an Aesir
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(IsAesir,tp,LOCATION_MZONE,0,1,nil)
end

--Target 1 opponent Effect Monster
function s.filter1(c,tp)
    return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsControler(1-tp) and c:IsAbleToChangeControler()
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,0,LOCATION_MZONE,1,nil,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
    local g=Duel.SelectTarget(tp,s.filter1,tp,0,LOCATION_MZONE,1,1,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end

--Take control and negate
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
        if Duel.GetControl(tc,tp) then
            --Negate effects while under your control
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e2)
            --Link trap to monster
            c:SetCardTarget(tc)
        end
    end
end

--Destroy trap if target leaves field
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=c:GetFirstCardTarget()
    return tc and eg:IsContains(tc)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end

--Search Fenrir when trap is destroyed
function s.thfilter(c)
    return c:IsCode(64203620) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end