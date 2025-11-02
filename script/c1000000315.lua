--Nordic Relic Ultima - Mjollnir
local s,id=GetID()
function s.initial_effect(c)
    --------------------------------
    --① Target 1 "Nordic" or "Aesir" monster in GY, Special Summon ignoring conditions, then equip this card to it
    --------------------------------
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    --------------------------------
    --② If the equipped monster battles, your opponent cannot activate cards or effects until the end of the Damage Step
    --------------------------------
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetCode(EFFECT_CANNOT_ACTIVATE)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(0,1) -- afecta al oponente
    e2:SetValue(function(e,re,tp)
        return true -- bloquea toda activación
    end)
    e2:SetCondition(s.actcon)
    c:RegisterEffect(e2)

    --------------------------------
    --③ If sent from field to GY while equipped to an "Aesir" monster: search 1 "Nordic Relic" Spell/Trap except itself
    --------------------------------
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,id+100)
    e3:SetCondition(s.thcon)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
end

--------------------------------
--① Special Summon & Equip
--------------------------------
function s.spfilter(c,e,tp)
    return (c:IsSetCard(0x42) or c:IsSetCard(0x4b)) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)~=0 then
        Duel.Equip(tp,c,tc)
        --Equip limit (solo a ese monstruo)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_EQUIP_LIMIT)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetValue(function(e,cc) return cc==tc end)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
    end
end

--------------------------------
--② Activación limitada durante batalla
--------------------------------
function s.actcon(e)
    local eqc=e:GetHandler():GetEquipTarget()
    if not eqc then return false end
    local a=Duel.GetAttacker()
    local d=Duel.GetAttackTarget()
    local ph=Duel.GetCurrentPhase()
    -- Mientras el monstruo equipado esté involucrado en batalla
    -- El oponente no puede activar nada hasta el final del Damage Step
    return (a==eqc or d==eqc) and (ph>=PHASE_BATTLE_START and ph<=PHASE_DAMAGE)
end

--------------------------------
--③ Buscar "Nordic Relic"
--------------------------------
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ec=c:GetPreviousEquipTarget()
    return c:IsPreviousLocation(LOCATION_ONFIELD) and ec and ec:IsSetCard(0x4b)
end
function s.thfilter(c)
    return c:IsSetCard(0x5042) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(id) and c:IsAbleToHand()
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
