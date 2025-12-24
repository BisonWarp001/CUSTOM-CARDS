--Nordic Horror - Fiery Armageddon (versión corregida)
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCondition(s.actcon)
    e1:SetTarget(s.target1)
    e1:SetOperation(s.activate1)
    c:RegisterEffect(e1)

    --Destroy when target leaves field
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetCondition(s.descon)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)

    --When this card is destroyed, add Fenrir
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end

--Target 1 monster
-- Condición de activación: debes controlar al menos 1 "Aesir"
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(IsAesir,tp,LOCATION_MZONE,0,1,nil)
end

function s.filter1(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function s.activate1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
        --Negate effects
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
        --Reduce ATK
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_UPDATE_ATTACK)
        e3:SetValue(-1000)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e3)

        --Link trap to monster
        c:SetCardTarget(tc)
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
    return c:IsCode(91697229) and c:IsAbleToHand()
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
