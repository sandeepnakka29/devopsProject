package com.vanguard.cto.bitbucket.plugin.impl;

import java.util.ArrayList;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.atlassian.bitbucket.hook.repository.PreRepositoryHookContext;
import com.atlassian.bitbucket.hook.repository.PullRequestMergeHookRequest;
import com.atlassian.bitbucket.hook.repository.RepositoryHookResult;
import com.atlassian.bitbucket.hook.repository.RepositoryMergeCheck;
import com.atlassian.bitbucket.i18n.I18nService;
import com.atlassian.bitbucket.pull.PullRequest;
import com.atlassian.bitbucket.pull.PullRequestParticipant;
import com.atlassian.bitbucket.pull.PullRequestParticipantStatus;

public class IsIAMApproverCheck implements RepositoryMergeCheck {
	
	private final I18nService i18nService;
	private static final Logger log = LoggerFactory.getLogger(IsIAMApproverCheck.class);
	
    public IsIAMApproverCheck(I18nService i18nService) {
    	this.i18nService = i18nService;
    }

	@Override
	public RepositoryHookResult preUpdate(PreRepositoryHookContext context, PullRequestMergeHookRequest request) {
		List<PullRequestParticipant> approvers = new ArrayList<PullRequestParticipant>();
		
		PullRequest pullRequest = request.getPullRequest();
		pullRequest.getReviewers().stream()
	    	.filter(p -> PullRequestParticipantStatus.APPROVED.equals(p.getStatus()))
	    	.forEach(p -> approvers.add(p));
		
        if(isMergeToMaster(pullRequest) && !isIamApproved(approvers)){
        	String summaryMsg = i18nService.getMessage("vanguard.plugin.pre.hook.isiamcheckrequired.summary");
            String detailedMsg = i18nService.getMessage("vanguard.plugin.pre.hook.isiamcheckrequired.detailed");
            return RepositoryHookResult.rejected(summaryMsg, detailedMsg);
        }
		return RepositoryHookResult.accepted();
	}
	
	private boolean isMergeToMaster(PullRequest pullRequest) {
		if(pullRequest.getToRef().toString().contains("refs/heads/master")) {
			return true;
		}
		return false;
	}

	private boolean isIamApproved(List<PullRequestParticipant> approvers) {
		for(PullRequestParticipant approver : approvers){
			//compare usernames
			if("UCQB".equals(approver.getUser().getName())){
				log.info("IsIAMApproverCheck.isIamApproved users: " + approver.getUser().getName());
				return true;
			}
		}
		return false;
	}

}
