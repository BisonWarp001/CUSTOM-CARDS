--Thunder of the Sky God
local s,id=GetID()
function s.initial_effect(c)
    --Activation: only if you control Slifer
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
    e1:SetCondition(s.actcon)
    e1:SetOperation(s.actop)
    c:RegisterEffect(e1)

   --② GY effect: banish to add Slifer and Normal Summon
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

--Check if you control any Slifer
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsCode(10000020) end,tp,LOCATION_MZONE,0,1,nil)
end

--Activate: create a global effect for card draw
function s.actop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_CARD,0,id)
    --Global effect for any Slifer you control
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_DESTROYED)
    e1:SetReset(RESET_PHASE+PHASE_END) -- lasts only this turn
    e1:SetCondition(s.drawcon_anyslifer)
    e1:SetOperation(s.drawop)
    Duel.RegisterEffect(e1,tp)
end

--Condition: any Slifer you control destroyed a monster by its effect
function s.drawcon_anyslifer(e,tp,eg,ep,ev,re,r,rp)
    for tc in aux.Next(eg) do
        local re=tc:GetReasonEffect()
        if re and re:GetHandler():IsCode(10000020) and re:GetHandler():IsControler(tp) then
            return true
        end
    end
    return false
end

--Operation: draw 1 card
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Draw(tp,1,REASON_EFFECT)
end

--② GY effect: banish self to search Slifer and Normal Summon
function s.thfilter(c)
    return c:IsCode(10000020) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,g)
        local slifer=g:GetFirst()
        if slifer:IsSummonable(true,nil) then
            -- Preguntar si el jugador quiere invocarlo
            if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
                Duel.BreakEffect()
                Duel.Summon(tp,slifer,true,nil)
            end
        end
    end
end
