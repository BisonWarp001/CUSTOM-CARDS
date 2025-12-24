--Divine Comeback
local s,id=GetID()
function s.initial_effect(c)
    --Activate (Continuous Trap)
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

----------------------------------------------
-- (1) Copy activation effect (Quick Effect)
----------------------------------------------
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.cpcon)
	e1:SetTarget(s.cptg)
	e1:SetOperation(s.cpop)
	c:RegisterEffect(e1)


    ----------------------------------------------
    -- (2) Tribute Divine-Beast to return this card (Quick Effect)
    ----------------------------------------------
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_RELEASE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+100)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetTarget(s.rstg)
    e2:SetOperation(s.rsop)
    c:RegisterEffect(e2)
end

------------------------------------------------
-- FILTERS
------------------------------------------------
function s.cpfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP)
        and not c:IsCode(id)
        and c:ListsCode(CARD_OBELISK, CARD_SLIFER, CARD_RA)
        and c:GetActivateEffect()~=nil
end

function s.dbfilter(c)
    return c:IsRace(RACE_DIVINE) and c:IsReleasable()
end

------------------------------------------------
-- (1) CONDITION: MP (yours) or BP (opponent)
------------------------------------------------
function s.cpcon(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()
    return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end

------------------------------------------------
-- (1) TARGET COPY EFFECT
------------------------------------------------
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then 
        return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.cpfilter(chkc)
    end
    if chk==0 then return Duel.IsExistingTarget(s.cpfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,s.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil)
end

------------------------------------------------
-- (1) OPERATION: COPY SPELL/TRAP ACTIVATION
------------------------------------------------
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then return end
    local te=tc:GetActivateEffect()
    if not te then return end

    -- take target & operation
    local tg=te:GetTarget()
    local op=te:GetOperation()

    -- safely attempt to use count limit
    if te.GetCountLimit and te:GetCountLimit() then
        te:UseCountLimit(tp)
    end

    if tg then
        tg(te,tp,Group.CreateGroup(),tp,0,0,nil,nil,1)
    end
    if op then
        op(te,tp,Group.CreateGroup(),tp,0,0,nil,nil)
    end
end

------------------------------------------------
-- (2) TARGET: Tribute Divine-Beast
------------------------------------------------
function s.rstg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then 
        return Duel.IsExistingMatchingCard(s.dbfilter,tp,LOCATION_MZONE,0,1,nil)
            and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
    end
    Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_MZONE)
end

------------------------------------------------
-- (2) OPERATION: Tribute → return card face-up
------------------------------------------------
function s.rsop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g=Duel.SelectMatchingCard(tp,s.dbfilter,tp,LOCATION_MZONE,0,1,1,nil)
    local tc=g:GetFirst()
    if tc and Duel.Release(tc,REASON_EFFECT)>0 then
        if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
        if Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_REMAIN_FIELD)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            c:RegisterEffect(e1)
        end
    end
end
