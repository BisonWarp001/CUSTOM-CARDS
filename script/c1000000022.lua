--Foundation Slime
local s,id=GetID()
function s.initial_effect(c)

    -------------------------------------------------------
    -- 1) Send 1 Divine-Beast from Deck, then search S/T that mentions it
    -------------------------------------------------------
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SEARCH+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.gytg)
    e1:SetOperation(s.gyop)
    c:RegisterEffect(e1)

    local e1b=e1:Clone()
    e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e1b)

    -------------------------------------------------------
    -- 2) Discard 1 card → Increase Level by 6
    -------------------------------------------------------
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_LVCHANGE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,{id,1})
    e2:SetCost(s.lvcost)
    e2:SetOperation(s.lvop)
    c:RegisterEffect(e2)
end

---------------------------------------------------------
-- EFFECT 1: Send Divine-Beast from Deck → Search S/T mentioning it
---------------------------------------------------------

-- Divine-Beast filter
function s.gyfilter(c,tp)
    return c:IsRace(RACE_DIVINE) and c:IsAbleToGrave()
        and Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK,0,1,nil,c)
end

-- Spell/Trap that mentions the Divine-Beast sent
function s.stfilter(c,dc)
    return c:IsSpellTrap() and c:IsAbleToHand() and c:ListsCode(dc:GetCode())
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_DECK,0,1,nil,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
    local tc=g:GetFirst()
    if not tc then return end

    if Duel.SendtoGrave(tc,REASON_EFFECT)==0 then return end

    -- buscar carta que lo mencione
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local sg=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_DECK,0,1,1,nil,tc)
    if #sg>0 then
        Duel.SendtoHand(sg,tp,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,sg)
    end
end


---------------------------------------------------------
-- EFFECT 2: Discard 1 card → Level +6
---------------------------------------------------------

function s.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) 
    end
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end

function s.lvop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsFaceup() and c:IsRelateToEffect(e) then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_LEVEL)
        e1:SetValue(6)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
    end
end
