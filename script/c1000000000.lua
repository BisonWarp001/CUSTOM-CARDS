--The God of Obelisk ANIME (MIKE CUSTOM)
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
    
    --Damage and Destroy
	local edamage=Effect.CreateEffect(c)
	edamage:SetDescription(aux.Stringid(id,0))
	edamage:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	edamage:SetType(EFFECT_TYPE_QUICK_O)
	edamage:SetCode(EVENT_FREE_CHAIN)
	edamage:SetRange(LOCATION_MZONE)
	edamage:SetCost(s.cost)
	edamage:SetTarget(s.destg)
	edamage:SetOperation(s.desop)
	c:RegisterEffect(edamage)
	
	--Soul Energy Max
	local emax=Effect.CreateEffect(c)
	emax:SetDescription(aux.Stringid(id,1))
	emax:SetType(EFFECT_TYPE_QUICK_O)
	emax:SetCode(EVENT_FREE_CHAIN)
	emax:SetRange(LOCATION_MZONE)
	emax:SetCost(s.cost)
	emax:SetCondition(s.atkcon)
	emax:SetOperation(s.atkop)
	c:RegisterEffect(emax)
	aux.GlobalCheck(s,function()
		--avatar
		local av=Effect.CreateEffect(c)
		av:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		av:SetCode(EVENT_ADJUST)
		av:SetCondition(s.avatarcon)
		av:SetOperation(s.avatarop)
		Duel.RegisterEffect(av,0)
	end)
end

---------------------------------------------------------------------------------

--Opponent cannot Tribute this card
function s.sumlimit(e,c)
    return not c:IsControler(e:GetHandlerPlayer())
end

--Cannot be used as material except DIVINE monsters
function s.matlimit(e,c,sumtype,tp)
    return not c:IsAttribute(ATTRIBUTE_DIVINE)
end

--Unaffected by Spells/Traps that remove from field & non-DIVINE monster effects
function s.leaveChk(c,category)
    local ex,tg=Duel.GetOperationInfo(0,category)
    return ex and tg~=nil and tg:IsContains(c)
end
function s.immval(e,te,c)
    local tc=te:GetOwner()
    return (te:IsMonsterEffect() and c~=tc and not tc:IsAttribute(ATTRIBUTE_DIVINE))
        or (te:IsSpellTrapEffect() and (s.leaveChk(c,CATEGORY_TOHAND) or s.leaveChk(c,CATEGORY_DESTROY)
        or s.leaveChk(c,CATEGORY_REMOVE) or s.leaveChk(c,CATEGORY_TODECK)
        or s.leaveChk(c,CATEGORY_RELEASE) or s.leaveChk(c,CATEGORY_TOGRAVE)))
end

--Other cards' effects only apply to this card for 1 turn
function s.stgop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local effs={c:GetCardEffect()}
    for _,eff in ipairs(effs) do
        if eff:GetOwner()~=c and not eff:IsHasProperty(EFFECT_FLAG_IGNORE_IMMUNE) then
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

function s.avfilter(c)
	local atktes={c:GetCardEffect(EFFECT_SET_ATTACK_FINAL)}
	local ae=nil
	local de=nil
	for _,atkte in ipairs(atktes) do
		if atkte:GetOwner()==c and atkte:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE)
				and atkte:IsHasProperty(EFFECT_FLAG_REPEAT)
				and atkte:IsHasProperty(EFFECT_FLAG_DELAY) then
			ae=atkte:GetLabel()
		end
	end
	local deftes={c:GetCardEffect(EFFECT_SET_DEFENSE_FINAL)}
	for _,defte in ipairs(deftes) do
		if defte:GetOwner()==c and defte:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE)
				and defte:IsHasProperty(EFFECT_FLAG_REPEAT)
				and defte:IsHasProperty(EFFECT_FLAG_DELAY) then
			de=defte:GetLabel()
		end
	end
	return c:IsOriginalCode(21208154) and (ae~=9999999 or de~=9999999)
end
function s.avatarcon(e,tp,eg,ev,ep,re,r,rp)
	return Duel.GetMatchingGroupCount(s.avfilter,tp,0xff,0xff,nil)>0
end
function s.avatarop(e,tp,eg,ev,ep,re,r,rp)
	local g=Duel.GetMatchingGroup(s.avfilter,tp,0xff,0xff,nil)
	g:ForEach(function(c)
		local atktes={c:GetCardEffect(EFFECT_SET_ATTACK_FINAL)}
		for _,atkte in ipairs(atktes) do
			if atkte:GetOwner()==c and atkte:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE)
				and atkte:IsHasProperty(EFFECT_FLAG_REPEAT)
				and atkte:IsHasProperty(EFFECT_FLAG_DELAY) then
				atkte:SetValue(s.avaval)
				atkte:SetLabel(9999999)
			end
		end
		local deftes={c:GetCardEffect(EFFECT_SET_DEFENSE_FINAL)}
		for _,defte in ipairs(deftes) do
			if defte:GetOwner()==c and defte:IsHasProperty(EFFECT_FLAG_SINGLE_RANGE)
				and defte:IsHasProperty(EFFECT_FLAG_REPEAT)
				and defte:IsHasProperty(EFFECT_FLAG_DELAY) then
				defte:SetValue(s.avaval)
				defte:SetLabel(9999999)
			end
		end
	end)
end
function s.avafilter(c)
	return c:IsFaceup() and c:GetCode()~=21208154
end
function s.avaval(e,c)
	local g=Duel.GetMatchingGroup(s.avafilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g==0 then
		return 100
	else
		local tg,val=g:GetMaxGroup(Card.GetAttack)
		if val>=9999999 then
			return val
		else
			return val+100
		end
	end
end
-----------------------------------------------------------------
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,nil,2,false,nil,c)
		and ((not c:IsHasEffect(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		and not c:IsHasEffect(EFFECT_FORBIDDEN) and not c:IsHasEffect(EFFECT_CANNOT_ATTACK)
		and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_ATTACK_ANNOUNCE)
		and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_ATTACK))
		or c:IsHasEffect(EFFECT_UNSTOPPABLE_ATTACK)) end
	local g=Duel.SelectReleaseGroupCost(tp,nil,2,2,false,nil,c)
	Duel.Release(g,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetHandler():GetAttack())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,1-tp,LOCATION_MZONE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,e:GetHandler():GetAttack(),REASON_EFFECT)
	Duel.Destroy(Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil),REASON_EFFECT)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsBattlePhase() and e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:CanAttack() and not c:IsImmuneToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE|PHASE_BATTLE|RESET_CHAIN)
		e1:SetValue(s.adval)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
		e2:SetCondition(s.damcon)
		e2:SetOperation(s.damop)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE|PHASE_BATTLE|RESET_CHAIN)
		c:RegisterEffect(e2)
		local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
		if #g==0 or ((c:IsHasEffect(EFFECT_DIRECT_ATTACK) or not g:IsExists(aux.NOT(Card.IsHasEffect),1,nil,EFFECT_IGNORE_BATTLE_TARGET)) and Duel.SelectYesNo(tp,31)) then
			Duel.CalculateDamage(c,nil)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACKTARGET)
			Duel.CalculateDamage(c,g:Select(tp,1,1,nil):GetFirst())
		end
	end
end
function s.adval(e,c)
	local g=Duel.GetMatchingGroup(nil,0,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	if #g==0 then
		return 9999999
	else
		local tg,val=g:GetMaxGroup(Card.GetAttack)
		if val<=9999999 then
			return 9999999
		else
			return val
		end
	end
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and e:GetHandler():GetAttack()>=9999999
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(ep,Duel.GetLP(ep)*100)
end