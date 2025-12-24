--The Winged Dragon of Ra ANIME (MIKE CUSTOM)
local s,id=GetID()
function s.initial_effect(c)
    --Requires 3 tributes to Normal Summon (cannot be Set)
    aux.AddNormalSummonProcedure(c,true,false,3,3)
    aux.AddNormalSetProcedure(c) -- Para que no pueda ser Set, simplemente no lo uses si no quieres que sea boca abajo

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

    --Unaffected by Spells/Traps that remove & non-DIVINE monsters
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

    --Original ATK/DEF become sum of tributed monsters
    local e9=Effect.CreateEffect(c)
    e9:SetType(EFFECT_TYPE_SINGLE)
    e9:SetCode(EFFECT_MATERIAL_CHECK)
    e9:SetValue(s.valcheck)
    c:RegisterEffect(e9)

    --Quick Effects (P2P Tribute)
    local eTrib=Effect.CreateEffect(c)
    eTrib:SetDescription(aux.Stringid(id,1))
    eTrib:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_RELEASE)
    eTrib:SetType(EFFECT_TYPE_QUICK_O)
    eTrib:SetCode(EVENT_FREE_CHAIN)
    eTrib:SetRange(LOCATION_MZONE)
    eTrib:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    eTrib:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL) end)
    eTrib:SetCost(s.tributocost)
    eTrib:SetOperation(s.tributoop)
    c:RegisterEffect(eTrib)

    --Special Summon from GY: Fénix / P2P
    local eSS=Effect.CreateEffect(c)
    eSS:SetDescription(aux.Stringid(id,0))
    eSS:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOGRAVE)
    eSS:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    eSS:SetCode(EVENT_SPSUMMON_SUCCESS)
    eSS:SetProperty(EFFECT_FLAG_DELAY)
    eSS:SetCountLimit(1,id)
    eSS:SetCondition(s.spcon)
    eSS:SetTarget(s.choose_target)
    eSS:SetOperation(s.choose_operation)
    c:RegisterEffect(eSS)
end

-- MATERIAL RESTRICTIONS
function s.matlimit(e,c,sumtype,tp)
    return not c:IsAttribute(ATTRIBUTE_DIVINE)
end
function s.sumlimit(e,c)
    return not c:IsControler(e:GetHandlerPlayer())
end

-- UNAFFECTED EFFECTS
function s.leaveChk(c,category)
    local ex,tg=Duel.GetOperationInfo(0,category)
    return ex and tg~=nil and tg:IsContains(c)
end
function s.immval(e,te,c)
    local tc=te:GetOwner()
    return (te:IsActiveType(TYPE_MONSTER) and c~=tc and not tc:IsOriginalAttribute(ATTRIBUTE_DIVINE))
        or (te:IsSpellTrapEffect() and (
            (c:GetDestination()>0 and c:GetReasonEffect()==te)
            or s.leaveChk(c,CATEGORY_TOHAND)
            or s.leaveChk(c,CATEGORY_DESTROY)
            or s.leaveChk(c,CATEGORY_REMOVE)
            or s.leaveChk(c,CATEGORY_TODECK)
            or s.leaveChk(c,CATEGORY_RELEASE)
            or s.leaveChk(c,CATEGORY_TOGRAVE)))
end

-- END PHASE RESET
function s.stgop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local effs={c:GetCardEffect()}
    for _,eff in ipairs(effs) do
        if eff:GetOwner()~=c and not eff:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE) then
            eff:Reset()
        end
    end
end

-- END PHASE SEND TO GY
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

-- SUM OF TRIBUTES ATK/DEF
function s.valcheck(e,c)
    local mg=c:GetMaterial()
    local atk,def=0,0
    for tc in aux.Next(mg) do
        atk=atk+math.max(tc:GetAttack(),0)
        def=def+math.max(tc:GetDefense(),0)
    end
    -- Apply original ATK/DEF based on tributes
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_BASE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(atk)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_SET_BASE_DEFENSE)
    e2:SetValue(def)
    c:RegisterEffect(e2)
end

-- P2P Tribute cost
function s.tributocost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroup(tp,aux.TRUE,1,e:GetHandler()) end
    local g=Duel.SelectReleaseGroup(tp,aux.TRUE,1,99,e:GetHandler())
    e:SetLabel(g:GetSum(Card.GetAttack))
    Duel.Release(g,REASON_COST)
end
function s.tributoop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local val=e:GetLabel()
    if not c:IsRelateToEffect(e) or val<=0 then return end
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(val)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e2)
end

-- Special Summon from GY
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetPreviousLocation()==LOCATION_GRAVE
end
function s.choose_target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end
function s.choose_operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
    local opt=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
    if opt==0 then
        -- Phoenix mode
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_INDESTRUCTABLE)
        e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e1:SetRange(LOCATION_MZONE)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_IMMUNE_EFFECT)
        e2:SetValue(function(e,te) return te:GetOwner()~=e:GetOwner() end)
        c:RegisterEffect(e2)
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
        e3:SetValue(1)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e3)
        -- Quick: Pay 1000 LP → send opponent's monsters to GY
        local e4=Effect.CreateEffect(c)
        e4:SetDescription(aux.Stringid(id,5))
        e4:SetCategory(CATEGORY_TOGRAVE)
        e4:SetType(EFFECT_TYPE_QUICK_O)
        e4:SetCode(EVENT_FREE_CHAIN)
        e4:SetRange(LOCATION_MZONE)
        e4:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
            if chk==0 then return Duel.CheckLPCost(tp,1000) end
            Duel.PayLPCost(tp,1000)
        end)
        e4:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
            if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)>0 end
            local g=Duel.GetFieldGroup(1-tp,LOCATION_MZONE,0)
            Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,1-tp,LOCATION_MZONE)
        end)
        e4:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
            local g=Duel.GetFieldGroup(1-tp,LOCATION_MZONE,0)
            if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT) end
        end)
        e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e4)
    else
        -- P2P mode from GY
        local lp=Duel.GetLP(tp)
        local cost=lp-1
        Duel.PayLPCost(tp,cost)
        local val=cost
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(val)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_UPDATE_DEFENSE)
        c:RegisterEffect(e2)
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_IMMUNE_EFFECT)
        e3:SetValue(function(e,te) return te:GetOwner()~=e:GetOwner() end)
        e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e3)
        -- Can also P2P Tribute
        local eTrib=Effect.CreateEffect(c)
        eTrib:SetDescription(aux.Stringid(id,1))
        eTrib:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_RELEASE)
        eTrib:SetType(EFFECT_TYPE_QUICK_O)
        eTrib:SetCode(EVENT_FREE_CHAIN)
        eTrib:SetRange(LOCATION_MZONE)
        eTrib:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
        eTrib:SetCost(s.tributocost)
        eTrib:SetOperation(s.tributoop)
        eTrib:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(eTrib)
    end
end
