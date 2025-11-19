--God's Anger
--The activation of this card, or its effects, cannot be negated, nor can its effects be negated.
--① When this card is activated: You can add 1 DIVINE monster from your Deck, GY or banishment to your hand. Once per turn, you can: Immediately after this effect resolves, Normal Summon 1 DIVINE monster. 
--② The control of Tribute Summoned monsters whose original names are "Slifer the Sky Dragon", "Obelisk the Tormentor", and "The Winged Dragon of Ra" cannot switch, also your opponent cannot Tribute or use them as material, and
--they are unaffected by your opponent's card effects.
--③ If a DIVINE monster(s) you control attacks, your opponent's cards and effects cannot be activated until the end of the Damage Step. 
--④ You can only activate 1 "God's Anger" per turn. 
local s,id=GetID()
local PROT = EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE

function s.initial_effect(c)
s.listed_names = {10000000,10000010,10000020}
    --------------------------------
    --① Activate: search 1 DIVINE monster + optional Normal Summon (once per turn)
    --------------------------------
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(PROT)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    --------------------------------
    --② Tribute Summoned Egyptian Gods: protections
    --------------------------------
    -- Immunity to opponent's effects
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetProperty(PROT)
    e2:SetTarget(s.godfilter)
    e2:SetValue(s.immval)
    c:RegisterEffect(e2)

    -- Cannot be tributed
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_UNRELEASABLE_SUM)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetProperty(PROT)
    e3:SetTarget(s.godfilter)
    e3:SetValue(1)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EFFECT_UNRELEASABLE_NONSUM)
    c:RegisterEffect(e4)

    -- Cannot be used as material
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e5:SetRange(LOCATION_SZONE)
    e5:SetTargetRange(LOCATION_MZONE,0)
    e5:SetProperty(PROT)
    e5:SetTarget(s.godfilter)
    e5:SetValue(1)
    c:RegisterEffect(e5)

    --------------------------------
    --③ If a DIVINE monster attacks, opponent cannot activate anything until end of Damage Step
    --------------------------------
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_FIELD)
    e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e6:SetCode(EFFECT_CANNOT_ACTIVATE)
    e6:SetRange(LOCATION_SZONE)
    e6:SetTargetRange(0,1)
    e6:SetValue(s.aclimit)
    e6:SetCondition(s.actcon)
    c:RegisterEffect(e6)
end

------------------------------------------------------------
-- ① Search and optional Normal Summon
------------------------------------------------------------
function s.thfilter(c)
    return c:IsAttribute(ATTRIBUTE_DIVINE) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
    if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
        Duel.ConfirmCards(1-tp,g)
        local tc=g:GetFirst()
        -- Preguntar si quieres hacer Normal Summon (solo una vez por turno)
        if tc:IsSummonable(true,nil) and Duel.GetFlagEffect(tp,id)==0 then
            if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
                Duel.BreakEffect()
                Duel.Summon(tp,tc,true,nil)
                Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
            end
        end
    end
end

------------------------------------------------------------
-- ② God protections
------------------------------------------------------------
function s.godfilter(e,c)
    return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_TRIBUTE) and
           (c:IsOriginalCode(10000000) or c:IsOriginalCode(10000010) or c:IsOriginalCode(10000020))
end
function s.immval(e,re)
    return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

------------------------------------------------------------
-- ③ Opponent cannot activate during attack
------------------------------------------------------------
function s.aclimit(e,re,tp)
    return true
end
function s.actcon(e)
    local tp=e:GetHandlerPlayer()
    local a=Duel.GetAttacker()
    local ph=Duel.GetCurrentPhase()
    if not a or a:IsControler(1-tp) or not a:IsAttribute(ATTRIBUTE_DIVINE) then return false end
    return (ph>=PHASE_BATTLE_START and ph<=PHASE_DAMAGE)
end
