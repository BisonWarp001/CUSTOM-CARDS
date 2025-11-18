--Azure Colossus Priestess
local s,id=GetID()
function s.initial_effect(c)
    ----------------------------------------
    -- ① Special Summon itself from hand (Main Phase)
    ----------------------------------------
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION) --
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    e1:SetCountLimit(1,id)
    c:RegisterEffect(e1)

    ----------------------------------------
    -- ② Reveal; send Obelisk or S/T mentioning it from hand or Deck
    ----------------------------------------
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND)
    e2:SetTarget(s.tgtg)
    e2:SetOperation(s.tgop)
    e2:SetCountLimit(1,{id,1})
    c:RegisterEffect(e2)

    ----------------------------------------
    -- ③ On Normal/Special Summon: Set Obelisk S/T from Deck or GY, can activate this turn
    ----------------------------------------
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,{id,2})
    e3:SetTarget(s.settg)
    e3:SetOperation(s.setop)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e4)
end

s.listed_names={10000000}
----------------------------------------
-- ① Special Summon from hand
----------------------------------------
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then 
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

----------------------------------------
-- ② Reveal, then send Obelisk or Obelisk S/T to GY
----------------------------------------
function s.tgfilter(c)
    return (
        c:IsCode(10000000) or  -- Obelisk the Tormentor
        (c:IsSpellTrap() and c:ListsCode(10000000))
    ) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
    end
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    --reveal itself
    Duel.ConfirmCards(1-tp,c)
    Duel.ShuffleHand(tp)
    --send Obelisk / Obelisk S/T
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end

----------------------------------------
-- ③ Set Obelisk S/T from Deck or GY; allow activation this turn
----------------------------------------
function s.setfilter(c)
    return c:IsSpellTrap() and c:ListsCode(10000000) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
    end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        Duel.SSet(tp,tc)
        --allow activation this turn (Quick-Play & Trap)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
        e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
        tc:RegisterEffect(e2)
    end
end
