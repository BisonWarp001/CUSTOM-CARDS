--Slifer the Sky Dragon (Anime)
--Scripted by You
local s,id=GetID()
function s.initial_effect(c)
     --Requires 3 tributes to Normal Summon (cannot be Set)
	--summon with 3 tribute
	local e1=aux.AddNormalSummonProcedure(c,true,false,3,3)
	local e2=aux.AddNormalSetProcedure(c)
    --Normal Summon cannot be negated
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    c:RegisterEffect(e1)

    --Opponent cannot Tribute this card
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_UNRELEASABLE_SUM)
    e2:SetValue(s.sumlimit)
    c:RegisterEffect(e2)
    
    --Control of this card cannot switch
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
    c:RegisterEffect(e3)

    --Cannot be used as material except DIVINE monsters
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_CANNOT_BE_MATERIAL)
    e4:SetValue(s.matlimit)
    c:RegisterEffect(e4)

    --Unaffected by Spells/Traps that remove from field & non-DIVINE monster effects
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCode(EFFECT_IMMUNE_EFFECT)
    e5:SetValue(s.immval)
    c:RegisterEffect(e5)

    --Cannot be turned Set
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_SINGLE)
    e6:SetCode(EFFECT_CANNOT_TURN_SET)
    e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e6:SetRange(LOCATION_MZONE)
    c:RegisterEffect(e6)

    --Other cards' effects only apply to this card for 1 turn
    local e7=Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e7:SetCode(EVENT_TURN_END)
    e7:SetRange(LOCATION_MZONE)
    e7:SetOperation(s.stgop)
    c:RegisterEffect(e7)

    --Once per turn, End Phase: if Special Summoned, send to GY
    local e8=Effect.CreateEffect(c)
    e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e8:SetCategory(CATEGORY_TOGRAVE)
    e8:SetRange(LOCATION_MZONE)
    e8:SetCountLimit(1)
    e8:SetCode(EVENT_PHASE+PHASE_END)
    e8:SetCondition(s.tgcon)
    e8:SetTarget(s.tgtg)
    e8:SetOperation(s.tgop)
    c:RegisterEffect(e8)
    
    --Gain ATK/DEF based on number of cards in your hand
    local e9=Effect.CreateEffect(c)
    e9:SetType(EFFECT_TYPE_SINGLE)
    e9:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
    e9:SetRange(LOCATION_MZONE)
    e9:SetCode(EFFECT_SET_BASE_ATTACK)
    e9:SetValue(s.adval)
    c:RegisterEffect(e9)
    
    local e10=e9:Clone()
    e10:SetCode(EFFECT_SET_BASE_DEFENSE)
    c:RegisterEffect(e10)
    
    --Summon Thunder Bullet effect
    local e11=Effect.CreateEffect(c)
    e11:SetDescription(aux.Stringid(id,0))
    e11:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_DESTROY)
    e11:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e11:SetCode(EVENT_SUMMON_SUCCESS)
    e11:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e11:SetRange(LOCATION_MZONE)
    e11:SetCondition(s.atkcon)
    e11:SetTarget(s.atktg)
    e11:SetOperation(s.atkop)
    c:RegisterEffect(e11)
    
    local e12=e11:Clone()
    e12:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
    c:RegisterEffect(e12)
    
    local e13=e12:Clone()
    e13:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e13)

end
-------------------------------------------------
--Material restriction function
function s.matlimit(e,c,sumtype,tp)
    if not c then return false end
    return not c:IsAttribute(ATTRIBUTE_DIVINE)
end

--Gain ATK/DEF based on number of cards in hand
function s.adval(e,c)
    return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)*1000
end

-------------------------------------------------
--Thunder Bullet effect
function s.atkfilter(c,p,e)
    return c:IsControler(p) and c:IsFaceup() and c:IsCanBeEffectTarget(e)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsFaceup()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return eg:IsContains(chkc) and s.atkfilter(chkc,1-tp,e) end
    if chk==0 then return eg:IsExists(s.atkfilter,1,nil,1-tp,e) end
    Duel.SetTargetCard(eg:Filter(s.atkfilter,nil,1-tp,e))
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetTargetCards(e):Filter(Card.IsFaceup,nil)
    if #g==0 then return end
    local dg=Group.CreateGroup()
    local c=e:GetHandler()
    for tc in aux.Next(g) do
        if tc:IsPosition(POS_FACEUP_ATTACK) then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(-2000)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD)
            tc:RegisterEffect(e1)
            if tc:GetAttack()==0 then dg:AddCard(tc) end
        elseif tc:IsPosition(POS_FACEUP_DEFENSE) then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_DEFENSE)
            e1:SetValue(-2000)
            e1:SetReset(RESET_EVENT|RESETS_STANDARD)
            tc:RegisterEffect(e1)
            if tc:GetDefense()==0 then dg:AddCard(tc) end
        end
    end
    if #dg==0 then return end
    Duel.BreakEffect()
    Duel.Destroy(dg,REASON_EFFECT)
end

-------------------------------------------------
--Your opponent cannot Tribute this card
function s.sumlimit(e,c)
    if not c then return false end
    return not c:IsControler(e:GetHandlerPlayer())
end
function s.relval(e,c)
    return c==e:GetHandler()
end

--Unaffected by Spells/Traps that remove from field & non-DIVINE monster effects
function s.leaveChk(c,category)
    local ex,tg=Duel.GetOperationInfo(0,category)
    return ex and tg~=nil and tg:IsContains(c)
end
function s.immval(e,te,c)
    local tc=te:GetOwner()
    return (te:IsActiveType(TYPE_MONSTER) and c~=tc) and not tc:IsOriginalAttribute(ATTRIBUTE_DIVINE)
        or (te:IsSpellTrapEffect() and ((c:GetDestination()>0 and c:GetReasonEffect()==te)
        or (s.leaveChk(c,CATEGORY_TOHAND) or s.leaveChk(c,CATEGORY_DESTROY) or s.leaveChk(c,CATEGORY_REMOVE)
        or s.leaveChk(c,CATEGORY_TODECK) or s.leaveChk(c,CATEGORY_RELEASE) or s.leaveChk(c,CATEGORY_TOGRAVE))))
end

--Last for 1 turn
function s.stgop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local effs={c:GetCardEffect()}
    for _,eff in ipairs(effs) do
        if eff:GetOwner()~=c and not eff:GetOwner():IsCode(0)
            and not eff:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE) and eff:GetCode()~=EFFECT_SPSUMMON_PROC
            and (eff:GetTarget()==aux.PersistentTargetFilter or not eff:IsHasType(EFFECT_TYPE_GRANT+EFFECT_TYPE_FIELD)) then
            eff:Reset()
        end
    end
end

--End Phase: if Special Summoned, send to GY
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        Duel.SendtoGrave(c,REASON_EFFECT)
    end
end